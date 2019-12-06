!
! Copyright (C) 2013 Quantum ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
! -----------------------------------------------------------------
! This program reads the prefix.wfc in G-space written by QE.
! It then preforms FFT to compute real space wfc.
! Next it takes products of these wfc to get f(r) functions
! Finally it preforms FFT back to G space and outputs f(G)
!
! Program is a copy of wfck2r written by Matteo Calandra.
! edits made by tjsmart
! 
!-----------------------------------------------------------------------
PROGRAM zfs
  !-----------------------------------------------------------------------
  !
  USE kinds, ONLY : DP
  USE io_files,  ONLY : prefix, tmp_dir, diropn
  USE mp_global, ONLY : npool, mp_startup,  intra_image_comm
  USE wvfct,     ONLY : nbnd, npwx
  USE klist,     ONLY : xk, nks, ngk, igk_k
  USE io_global, ONLY : ionode, ionode_id, stdout
  USE mp,        ONLY : mp_bcast, mp_barrier
  USE mp_world,  ONLY : world_comm
  USE wavefunctions_module, ONLY : evc
  USE io_files,             ONLY : nwordwfc, iunwfc
  USE gvect, ONLY : ngm, g 
  USE gvecs, ONLY : nls
  USE noncollin_module, ONLY : npol, nspin_mag, noncolin
  USE environment,ONLY : environment_start, environment_end
  USE fft_base,  only : dffts, dfftp
  USE scatter_mod,  only : gather_grid
  USE fft_interfaces, ONLY : fwfft, invfft

  !
  IMPLICIT NONE
  CHARACTER (len=256) :: outdir
  CHARACTER(LEN=256), external :: trimcheck
  character(len=256) :: filename
  INTEGER            :: npw, iunitout,ios,ik,i,iuwfcr,lrwfcr,ibnd, ig, is

  character(len=10), parameter  :: indent="          "
  complex(dp), allocatable      :: evc1_r(:), evc2_r(:), f1_r(:), f2_r(:), f3_r(:)
  complex(dp), allocatable      :: f1_G(:), f2_G(:), f3_G(:)
  integer                       :: ibnd1, ibnd2
  character(len=256)            :: dump_dir, dump_w1, dump_w2, dump_f1, dump_f2, dump_f3
  character(len=256)            :: dump_wr1, dump_wr2, dump_fr1, dump_fr2, dump_fr3

  NAMELIST / inputpp / outdir, prefix, ibnd1, ibnd2

  !
  !
#if defined(__MPI)

  CALL mp_startup ( )
#endif
  CALL environment_start ( 'ZFS' )

  prefix = 'pwscf'
  CALL get_environment_variable( 'ESPRESSO_TMPDIR', outdir )
  IF ( TRIM( outdir ) == ' ' ) outdir = './'

  IF ( npool > 1 ) CALL errore('bands','pools not implemented',npool)
  !
  IF ( ionode )  THEN
     !
     CALL input_from_file ( )
     ! 
     READ (5, inputpp, err = 200, iostat = ios)
200  CALL errore ('ZFS', 'reading inputpp namelist', ABS (ios) )
     !
     tmp_dir = trimcheck (outdir)
     ! 
  END IF

  ! ... Broadcast variables
  CALL mp_bcast( tmp_dir, ionode_id, world_comm )
  CALL mp_bcast( prefix, ionode_id, world_comm )

  !   Now allocate space for pwscf variables, read and check them.
  CALL read_file
  call openfil_pp
  CALL init_us_1

  ALLOCATE ( evc1_r(dffts%nnr) , evc2_r(dffts%nnr) )
  evc1_r = (0.d0, 0.d0)
  evc2_r = (0.d0, 0.d0)
  ALLOCATE ( f1_r(dffts%nnr) , f2_r(dffts%nnr) , f3_r(dffts%nnr) )
  f1_r = (0.d0, 0.d0)
  f2_r = (0.d0, 0.d0)
  f3_r = (0.d0, 0.d0)

  call execute_command_line('if [ ! -d qe.dump ]; then mkdir qe.dump; fi')
  dump_dir = "qe.dump"

  dump_w1 = trim(dump_dir) // "/wfc1.txt"
  dump_w2 = trim(dump_dir) // "/wfc2.txt"
  dump_f1 = trim(dump_dir) // "/f1_G.txt"
  dump_f2 = trim(dump_dir) // "/f2_G.txt"
  dump_f3 = trim(dump_dir) // "/f3_G.txt"

  dump_wr1 = trim(dump_dir) // "/wfc1_r.txt"
  dump_wr2 = trim(dump_dir) // "/wfc2_r.txt"
  dump_fr1 = trim(dump_dir) // "/f1_r.txt"
  dump_fr2 = trim(dump_dir) // "/f2_r.txt"
  dump_fr3 = trim(dump_dir) // "/f3_r.txt"

  !
  !
  !  Begin ZFS
  !
  !
  write(6,*) ''
  write(6,*) indent, '---------------------------'


  ! read in spin up wavefunctions
  ik = 1
  npw = ngk(ik)
  CALL davcio (evc, 2*nwordwfc, iunwfc, ik, - 1)

  ! write wfc's
  write(6,*) indent, 'Writing ', dump_w1
  call write_wfc(evc(:,ibnd1), npw, dump_w1)
  write(6,*) indent, 'Writing ', dump_w2
  call write_wfc(evc(:,ibnd2), npw, dump_w2)

  ! transfer to evc_r which is defined on a smooth grid
  do ig = 1, npw
    evc1_r (nls (igk_k(ig,ik) ) ) = evc (ig, ibnd1)
    evc2_r (nls (igk_k(ig,ik) ) ) = evc (ig, ibnd2)
  enddo

  ! compute evc_r
  write(6,*) indent, 'Computing evc1_r'
  CALL invfft ('Wave', evc1_r(:), dffts)
  write(6,*) indent, 'Computing evc2_r'
  CALL invfft ('Wave', evc2_r(:), dffts)

  ! write real wfc's
  write(6,*) indent, 'Writing ', dump_wr1
  call write_wfc(evc1_r(:), dffts%nnr, dump_wr1)
  write(6,*) indent, 'Writing ', dump_wr2
  call write_wfc(evc2_r(:), dffts%nnr, dump_wr2)

  ! compute f1(r), f2(r), and f3(r)
  write(6,*) indent, 'Computing f1_r'
  f1_r = conjg(evc1_r) * evc1_r
  write(6,*) indent, 'Computing f2_r'
  f2_r = conjg(evc2_r) * evc2_r
  write(6,*) indent, 'Computing f3_r'
  f3_r = conjg(evc1_r) * evc2_r

  ! write real f(r)
  write(6,*) indent, 'Writing ', dump_fr1
  call write_wfc(f1_r(:), dffts%nnr, dump_fr1)
  write(6,*) indent, 'Writing ', dump_fr2
  call write_wfc(f2_r(:), dffts%nnr, dump_fr2)
  write(6,*) indent, 'Writing ', dump_fr3
  call write_wfc(f3_r(:), dffts%nnr, dump_fr3)

  ! compute f1(G), f2(G), and f3(G)
  write(6,*) indent, 'Computing f1_G'
  CALL fwfft ('Wave', f1_r(:), dffts)
  write(6,*) indent, 'Computing f2_G'
  CALL fwfft ('Wave', f2_r(:), dffts)
  write(6,*) indent, 'Computing f3_G'
  CALL fwfft ('Wave', f3_r(:), dffts)

  ALLOCATE(f1_G(npw), f2_G(npw), f3_G(npw))
  f1_G = (0.d0, 0.d0)
  f2_G = (0.d0, 0.d0)
  f3_G = (0.d0, 0.d0)

  ! reshape and store f1(G), f2(G), and f3(G)
  ik = 1
  f1_G(1:npw)  = f1_r( nls( igk_k(1:npw, ik) ) )
  f2_G(1:npw)  = f2_r( nls( igk_k(1:npw, ik) ) )
  f3_G(1:npw)  = f3_r( nls( igk_k(1:npw, ik) ) )

  ! write f(G) to files
  write(6,*) indent, 'Writing ', dump_f1
  call write_wfc(f1_G(:), npw, dump_f1)
  write(6,*) indent, 'Writing ', dump_f2
  call write_wfc(f2_G(:), npw, dump_f2)
  write(6,*) indent, 'Writing ', dump_f3
  call write_wfc(f3_G(:), npw, dump_f3)

  write(6,*) indent, '---------------------------'



  ! print *, "HERE is f_G (dense) number ", 1
  ! do ig = 1, size(f1_G(:))
  !   print *, dble(f1_G(ig)), dimag(f1_G(ig))
  ! end do
  ! print *
  ! print *, "HERE is f_G (dense) number ", 2
  ! do ig = 1, size(f2_G(:))
  !   print *, dble(f2_G(ig)), dimag(f2_G(ig))
  ! end do
  ! print *
  ! print *, "HERE is f_G (dense) number ", 3
  ! do ig = 1, size(f3_G(:))
  !   print *, dble(f3_G(ig)), dimag(f3_G(ig))
  ! end do

  !
  !
  !

  ! if(ionode) close(iuwfcr)
  ! DEALLOCATE (evc_r)
  DEALLOCATE (evc1_r)
  DEALLOCATE (evc2_r)
  DEALLOCATE (f1_r)
  DEALLOCATE (f2_r)
  DEALLOCATE (f3_r)
  DEALLOCATE (f1_G)
  DEALLOCATE (f2_G)
  DEALLOCATE (f3_G)

  CALL environment_end ( 'ZFS' )

  CALL stop_pp
  STOP

end PROGRAM zfs



subroutine write_grid(grid, npw, dim_G, file_G)
  ! write grid to formatted file

      integer, intent(in)                                 :: npw, dim_G
      integer, dimension(npw, dim_G), intent(in)          :: grid
      character(len=256), intent(in)                      :: file_G
      integer                                             :: i ! dummy index

      open (unit=10, file=file_G)
      do i = 1, npw
          write (10,*) grid(i,:)
      end do
      ! TODO -- add format to print?
      close (10)

  end subroutine write_grid


  subroutine write_wfc(wfc, npw, file_w)
  ! write wfc to formatted file
    USE kinds, ONLY : DP

      integer, intent(in)                                 :: npw
      complex(DP), dimension(npw), intent(in)             :: wfc
      character(len=256), intent(in)                      :: file_w
      integer                                             :: i ! dummy index

      open (unit=10, file=file_w)
      do i = 1, npw
          write (10,100) real(wfc(i)), " , ", aimag(wfc(i))
      end do
      100 format(2x,e13.6e2,a3,e13.6e2)
      close(10)

  end subroutine write_wfc
