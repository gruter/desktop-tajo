#!/usr/bin/env bash

## 매개변수 선언.
TAJO_GIT=
TAJO_GIT_TAG=

## 실행명령으로 매개변수 대입.
## -g: git 레포지토리 주소.
## -t: git 레포지토리의 branch나 tag이름.
while [ $# -gt 0 ]
do
  case "$1" in
    -g)
      shift; TAJO_GIT=$1;;
    -t)
      shift; TAJO_GIT_TAG=$1;;
    -*)
      echo "unrecognized option: $1"; exit 0;;
    *)
      break;
      ;;
  esac
  shift
done

## 입력 매개변수가 없을경우 기본값 대입.
if [ -z $TAJO_GIT ]
then
   TAJO_GIT="https://github.com/apache/tajo.git"
fi
if [ -z $TAJO_GIT_TAG ]
then
   TAJO_GIT_TAG="master"
fi

## 환경변수 생성.
home=`dirname "$0"`
home=`cd "$bin"; pwd`
build_home=$home/build

## 작업 디렉토리 생성.
mkdir -p $build_home/source-tajo

## tajo 소스 clone.
cd $build_home/source-tajo
git clone -b $TAJO_GIT_TAG $TAJO_GIT

## tajo 소스 빌드.
cd tajo
mvn clean install -Pdist -DskipTests -Dtar

## 빌드된 tajo패키지 작업디렉토리에 풀기.
cd $build_home
tar -xvf source-tajo/tajo/tajo-dist/target/tajo-*.gz

## tajo버전 확인.
cd tajo-*
tajo_version=`pwd`
tajo_version=`basename $tajo_version`

## desktop버전확인.
## desktop버전규칙은 {tajo_version}-desktop-r{desktop_revision}
## {tajo_version}는 빌드한 tajo버전을 사용.
## {desktop_revision}는 이전 버전을 파일에 저장해두었다가 1씩증가.
## 버전이 저장된 파일이 없다면 1.
cd $home
revision=1
if [ -f "desktop_version.txt" ]
then
   versions=`cat desktop_version.txt`
   versions=($versions)
   if [ ${versions[0]} = $tajo_version ]
   then
      revision=$((${versions[1]} + 1))
      echo $tajo_version > desktop_version.txt
      echo $revision >> desktop_version.txt
   else
      echo $tajo_version > desktop_version.txt
      echo $revision >> desktop_version.txt
   fi
else
   echo $tajo_version > desktop_version.txt
   echo $revision >> desktop_version.txt
fi
desktop_version=${tajo_version}-desktop-r${revision}

## tajo패키지명을 desktop 버전으로 변경.
cd $build_home
mv $tajo_version $desktop_version

## desktop 소스받아 패키지만들기.
curl -LOk https://github.com/gruter/desktop-tajo/archive/master.zip
unzip master.zip
cd desktop-tajo-master
tar -cvf source-desktop.tar *

## tajodp desktop 소스 머지.
cd $build_home/$desktop_version
tar -xvf $build_home/desktop-tajo-master/source-desktop.tar

## 최종 desktop 패키지 만들기.
cd $build_home
tar -zcvf ${desktop_version}.tar.gz $desktop_version
mv ${desktop_version}.tar.gz $home

## 작업디렉토리 지우기.
cd $home
rm -rf build
