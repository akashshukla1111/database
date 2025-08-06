# Aliases for version checking commands
# Add these to your ~/.zshrc file

source .helper.sh

# UI version - check decant-api, gdm-web with qa,default,stg environments
alias ui='fs -frs gdm-web,idc,decant-api,isc/us-wm-fc,us-wm-manual-fc,default-fc us-wm-manual-fc.yml,us-wm-fc.yml,default-fc-stg.yml,fc-pre-main-merge.yml,default-fc.yml | ss qa,test,default,stg -s'
alias uiqa='fs -frs gdm-web,idc,decant-api/us-wm-fc,us-wm-manual-fc us-wm-manual-fc.yml,us-wm-fc.yml | ss qa,test -s'
alias uidefault='fs -frs gdm-web,idc,decant-api/default-fc default-fc-stg.yml,fc-pre-main-merge.yml,default-fc.yml  | ss -s'
# Backend version - check wms-receiving, gdm, os, aos, nte, loading with qa,default environments
alias b='fs -frs wms-receiving,gdm,os,aos,nte,loading/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search qa,default -s'
# Environment specific aliases
alias qa='fs -frs wms-receiving,gdm,os,aos,nte,loading/fc,us-wm-fc us-wm-fc.yml | search qa -s'
alias default='fs -frs wms-receiving,gdm,os,aos,nte,loading/fc,default-fc fc-pre-main-merge.yml | search default,stg -s'

function rcv() {
  echo "$log 'fs -frs wms-receiving/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $2 -s'"
  fs -frs wms-receiving/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s
}
function gdm() {
  echo "fs -frs gdm/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s"
  fs -frs gdm/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s
}
function inv() {
  echo "fs -fr isc/us-wm-fc,default-fc us-wm-fc.yml,pre-main.yml | ss  $1 -s"
  fs -fr isc/us-wm-fc,default-fc us-wm-fc.yml,pre-main.yml | ss $1 -s
}
function os() {
  echo "fs -frs os/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s"
  fs -frs os/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s
}
function aos() {
  echo "fs -frs aos/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s"
  fs -frs aos/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s
}
function fes() {
  echo "fs -frs nte/default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s"
  fs -frs nte/default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s
}
function loading() {
  echo "fs -frs loading/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s"
  fs -frs loading-server/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s
}



function f() {
  log="Running command for $1 with stages $2 -->"
  arg=$([ "${3:-"-s"}" = "-ss" ] && echo "" || echo "${3:-"-s"}")
  search_cmd="search $2 $arg ${4}"
  local sledge_files=""
  local search_files=""

  case "$1" in
    -rcv | rcv )
        sledge_files="fs -frs wms-receiving/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml"
        search_files="fs -fr wms-receiving/fc,default-fc,us-wm-fc .yml";;
    -gdm | gdm )
        sledge_files="fs -frs gdm/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml"
        search_files="fs -fr gdm/fc,default-fc,us-wm-fc .yml";;
    -loc | loc | location | -location )
        sledge_files="fs -fr gls-location/fc,us-wm-fc,default-fc us-wm-fc.yml,pre-main"
        search_files="fs -fr gls-location/fc,us-wm-fc,default-fc .yml";;
    -inv | inv )
        sledge_files="fs -fr isc/us-wm-fc,default-fc us-wm-fc.yml,pre-main.yml"
        search_files="fs -fr isc/us-wm-fc,default-fc .yml";;
    -os | os )
        sledge_files="fs -frs os/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml"
        search_files="fs -fr os/fc,default-fc,us-wm-fc .yml";;
    -aos | aos )
        sledge_files="fs -frs aos/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml"
        search_files="fs -fr aos/fc,default-fc,us-wm-fc .yml";;
    -fes | fes )
        sledge_files="fs -frs nte/default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml"
        search_files="fs -fr nte/default-fc,us-wm-fc .yml";;
    -loading | loading )
        sledge_files="fs -frs loading/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml"
        search_files="fs -fr loading/fc,default-fc,us-wm-fc .yml";;
    -inb | inb )
        sledge_files="fs -frs wms-receiving,gdm,isc,slotting,uwms-location/fc,us-wm-fc us-wm-fc.yml"
        search_files="fs -fr wms-receiving,gdm,isc,slotting,uwms-location/fc,us-wm-fc .yml";;
    -outb | outb )
        sledge_files="fs -frs os,aos,nte,loading,uli/fc,us-wm-fc us-wm-fc.yml"
        search_files="fs -fr os,aos,nte,loading,uli/fc,us-wm-fc .yml";;
    ui | -ui )
        sledge_files="fs -frs gdm-web,idc,decant-api/us-wm-fc,us-wm-manual-fc us-wm-manual-fc.yml,us-wm-fc.yml"
        search_files="fs -fr gdm-web,idc,decant-api/us-wm-fc,us-wm-manual-fc .yml";;
    inout | -inout )
        sledge_files="fs -frs wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,isc,uli/fc,us-wm-fc us-wm-fc.yml"
        search_files="fs -fr wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,isc,uli/fc,us-wm-fc .yml";;  
    -all | all )
        sledge_files="fs -frs wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,uli,idc,decant-api/fc,us-wm-fc,us-wm-manual-fc us-wm-fc.yml,us-wm-manual-fc.yml"
        search_files="fs -fr wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,uli,idc,decant-api/fc,us-wm-fc,us-wm-manual-fc .yml";;          
    *)
        echo "${RED}Invalid command: ${RST} $1"
        return 1
        ;;
  esac

  # Set valid to true if any argument is -full
  valid=false
  for arg in "$@"; do
    if [ "$arg" = "-full" ]; then
      valid=true
      break
    fi
  done

  if [ "$valid" = true ]; then
    echo "$log ${BRI_WHT} [$search_files | $search_cmd]"
     eval "$search_files" | eval "$search_cmd"
  else
    echo "$log ${BRI_WHT} [$sledge_files | $search_cmd]"
     eval "$sledge_files" | eval "$search_cmd"
  fi
}

