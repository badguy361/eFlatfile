!Edit by Yeh,ting-yu 2015/10/05
program rupture_distance
implicit none
integer,parameter :: n=32570
real, parameter :: pi=3.14159
integer :: i,j,k,m,indexx
integer :: fn(n),fr(n)
real :: mw(n),strike(n),dip(n),dep(n)
real (kind=8) :: lon(n),lat(n),slon(n),slat(n)
real :: A(n),AR(n),rupl(n),rupw(n),mindist(n)
character :: EQ_ID(n)
character(len=25) :: sta(n)
integer :: xgrid(n),ygrid(n),allgrid(n)
real,allocatable :: meshx(:),meshy(:),meshz(:),xp(:),yp(:),zp(:)
real,allocatable :: rx(:),ry(:),rz(:),rxp(:),ryp(:),rzp(:)
real,allocatable :: rrx(:),rry(:),rrz(:),dist(:)

open(11,file="2020.fy_in_plane1.txt")
open(12,file="2020.fy_out_plane1.txt")
!open(13,file="mesh/origin_revised_not_spinned.txt")
!open(14,file="mesh/roty.dat")
!open(15,file="mesh/rotz.txt")

!利用經驗公式計算斷層面積、長寬比、斷層破裂面長度與寬度
!=================================================================
!    計算斷層面積                                                |
!    Wells and Coppersmith(1994):                                |
!    log(A)=-3.49+0.91*M     sigma(log(A))=0.24                  |
!    震矩規模適用範圍：4.8~7.9                                   |
!                                                                |
!=================================================================
!    NGA計畫中計算斷層破裂面之長寬比                             |
!    log(AR)=(0.01752-0.00472*FN-0.01099*FR)*(M-4)**3.097        |
!                                                                |
!=================================================================
!讀資料
do i=1,n
	read(11,*) EQ_ID(i),lon(i),lat(i),mw(i),dep(i),strike(i),dip(i),&
	&fn(i),	fr(i),slon(i),slat(i),sta(i)
	A(i)=10**(-3.49+0.91*mw(i))
	AR(i)=10**((0.01752-0.00472*fn(i)-0.01099*fr(i))*(mw(i)-4)**3.097)
	rupl(i)=sqrt(A(i)*AR(i))
	rupw(i)=sqrt(A(i)/AR(i))
!切割網格點==================================
xgrid(i)=anint(rupw(i)/100.8/0.001)  !x方向格點數
if (mod(xgrid(i),2)==0) xgrid(i)=xgrid(i)+1  !X方向網格數要是奇數，震源兩側均等格點數量

ygrid(i)=anint(rupl(i)/111.2/0.001)  !Y方向格點數
if (mod(ygrid(i),2)==0) ygrid(i)=ygrid(i)+1  !Y方向網格數要是奇數，震源兩側均等格點數量

!總格點數====================================
allgrid(i)=xgrid(i)*ygrid(i)

write(*,*) rupl(i),rupw(i),xgrid(i),ygrid(i),allgrid(i)

allocate(meshx(0:allgrid(i)),meshy(0:allgrid(i)),meshz(allgrid(i)))
allocate(xp(allgrid(i)),yp(allgrid(i)),zp(allgrid(i)))
allocate(rx(allgrid(i)),ry(allgrid(i)),rz(allgrid(i)))
allocate(rxp(allgrid(i)),ryp(allgrid(i)),rzp(allgrid(i)))
allocate(rrx(allgrid(i)),rry(allgrid(i)),rrz(allgrid(i)))

!找左上角的點XY值============================
meshx(0)=lon(i)-(int(xgrid(i)/2))*0.001-0.001  !產生X方向格點
do m=1,ygrid(i)-1
	do k=1,xgrid(i)
		meshx(k)=meshx(k-1)+0.001
		meshx(k+m*(xgrid(i)))=meshx(k)
	!	write(14,*)k,m,k+m*(xgrid(i)),meshx(k)
	end do
end do

meshy(1)=lat(i)+(int(ygrid(i)/2))*0.001  !產生Y方向格點
do k=1,ygrid(i)-1
	meshy(k*xgrid(i)+1)=meshy((k-1)*xgrid(i)+1)-0.001
end do
do k=0,ygrid(i)-1
	do m=1,xgrid(i)-1
		meshy(k*xgrid(i)+1+m)=meshy(k*xgrid(i)+m)
	end do
end do

do m=1,allgrid(i)      !產生Z方向格點
	meshz(m)=-dep(i)*1000
end do
!===========================================

!以Y軸為旋轉軸將斷層面旋轉dip角後，再以Z軸為旋轉軸將斷層面旋轉strike角
do k=1,allgrid(i)
		xp(k)=(meshx(k)-lon(i))*100800
		yp(k)=(meshy(k)-lat(i))*111200
		zp(k)=(meshz(k)+dep(i)*1000)
		!zp(k)=meshz(k)
		call roty(xp(k),yp(k),zp(k),dip(i),rx(k),ry(k),rz(k))
		rx(k)=(rx(k)/100800)+lon(i)
		ry(k)=(ry(k)/111200)+lat(i)
		rz(k)=(rz(k)+meshz(k))
		!rz(k)=rz(k)

		rxp(k)=(rx(k)-lon(i))*100800
		ryp(k)=(ry(k)-lat(i))*111200
		rzp(k)=rz(k)
		!rzp(k)=rz(k)+dep(i)*1000
		call rotz(rxp(k),ryp(k),rzp(k),strike(i),rrx(k),rry(k),rrz(k))
		rrx(k)=(rrx(k)/100800)+lon(i)
		rry(k)=(rry(k)/111200)+lat(i)
		rrz(k)=rrz(k)
		!rrz(k)=rrz(k)+meshz(k)

		!write(14,*) rx(k),ry(k),rz(k)

		if (i==4) then
		  write(13,*) meshx(k),meshy(k),meshz(k)
     	  write(15,'(3F16.9)') rrx(k),rry(k),rrz(k)/1000.
        end if
end do

allocate(dist(allgrid(i)))
!計算測站到斷層面上每一點的距離===========
do m=1,allgrid(i)
	call mesh_dist(rrx(m),rry(m),rrz(m)/1000,slon(i),slat(i),dist(m))
	!write(14,*) rrx(m),rry(m),rrz(m)/1000,slon(i),slat(i),dist(m)
end do

mindist(i)=1000000.
!計算測站到斷層面的最短距離(找最小值)=====
do k=1,allgrid(i)
	if ( dist(k)<=mindist(i) ) then
	mindist(i)=dist(k)
	indexx = k
	else
	mindist(i)=mindist(i)
	end if
end do

write(12,'(A8,4f16.9)') sta(i),mindist(i),rrx(indexx),rry(indexx),rrz(indexx)/1000.

deallocate(meshx,meshy,meshz)
deallocate(xp,yp,zp)
deallocate(rx,ry,rz)
deallocate(rxp,ryp,rzp)
deallocate(rrx,rry,rrz)
deallocate(dist)

end do
end

!副程式===================================
subroutine rotx(xp,yp,zp,beta,rx,ry,rz)
	implicit none
	real :: xp,yp,zp
	real :: beta,A
	real :: rx,ry,rz
	real, parameter :: pi=3.14159

	A=-beta*pi/180.
	rx=xp
	ry=yp*cos(A)-zp*sin(A)
	rz=yp*sin(A)-zp*cos(A)

	return
end

subroutine roty(xp,yp,zp,beta,rx,ry,rz)
	implicit none
	real :: xp,yp,zp
	real :: beta,A
	real :: rx,ry,rz
	real, parameter :: pi=3.14159

	A=beta*pi/180.
	rx=xp*cos(A)+zp*sin(A)
	ry=yp
	rz=xp*-sin(A)+zp*cos(A)

	return
end

subroutine rotz(rxp,ryp,rzp,delta,rrx,rry,rrz)
	implicit none
	real :: rxp,ryp,rzp
	real :: delta,A
	real :: rrx,rry,rrz
	real, parameter :: pi=3.14159

	A=delta*pi/180.
	rrx=rxp*cos(A)+ryp*sin(A)
	rry=-rxp*sin(A)+ryp*cos(A)
	rrz=rzp

	return
end

subroutine mesh_dist(rrx,rry,rrz,slon,slat,dist)
implicit none
real :: rrx,rry,rrz
real :: dist
real (kind=8) :: slon,slat

dist=(((rrx-slon)*102)**2+((rry-slat)*111)**2+rrz**2)**0.5

return
end

