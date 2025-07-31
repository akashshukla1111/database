# Aliases for version checking commands
# Add these to your ~/.zshrc file

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
  echo "fs -frs loading-server/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s"
  fs -frs loading-server/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search $1 -s
}

function v() {
  log="running command for $1 with stages $2 -->"
  search_cmd="search $2 $3"
  
  case "$1" in
    -rcv | rcv )
      # echo "$log [fs -frs wms-receiving/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | $search_cmd]"
      # fs -frs wms-receiving/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | eval "$search_cmd";;
      find_cmd="fs -frs wms-receiving/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml";;
    -inb | inb  )
      # echo "$log [fs -frs wms-receiving,gdm,isc,slotting,uwms-location/fc,us-wm-fc us-wm-fc.yml | $search_cmd]"
      # fs -frs wms-receiving,gdm,isc,slotting,uwms-location/fc,us-wm-fc us-wm-fc.yml | eval "$search_cmd";;
      find_cmd="fs -frs wms-receiving,gdm,isc,slotting,uwms-location/fc,us-wm-fc us-wm-fc.yml";;    
    -outb | outb )
      # echo "$log [fs -frs os,aos,nte,loading,uli/fc,us-wm-fc us-wm-fc.yml | $search_cmd]"
      # fs -frs os,aos,nte,loading,uli/fc,us-wm-fc us-wm-fc.yml | eval "$search_cmd";;
      find_cmd="fs -frs os,aos,nte,loading,uli/fc,us-wm-fc us-wm-fc.yml";;
    ui | -ui)
      # echo "$log [fs -frs gdm-web,idc,decant-api/us-wm-fc,us-wm-manual-fc us-wm-manual-fc.yml,us-wm-fc.yml | $search_cmd]"
      # fs -frs gdm-web,idc,decant-api/us-wm-fc,us-wm-manual-fc us-wm-manual-fc.yml,us-wm-fc.yml | eval "$search_cmd";;
      find_cmd="fs -frs gdm-web,idc,decant-api/us-wm-fc,us-wm-manual-fc us-wm-manual-fc.yml,us-wm-fc.yml";;
    inout | -inout)
      # echo "$log [fs -frs wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,isc,uli/fc,us-wm-fc us-wm-fc.yml | $search_cmd]"
      # fs -frs wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,isc,uli/fc,us-wm-fc us-wm-fc.yml | eval "$search_cmd";;
      find_cmd="fs -frs wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,isc,uli/fc,us-wm-fc us-wm-fc.yml";;
    -all | all | * )
      # echo "$log [fs -frs wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,uli,idc,decant-api/fc,us-wm-fc,us-wm-manual-fc us-wm-fc.yml,us-wm-manual-fc.yml | $search_cmd]"
      # fs -frs wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,uli,idc,decant-api/fc,us-wm-fc,us-wm-manual-fc us-wm-fc.yml,us-wm-manual-fc.yml | eval "$search_cmd";;
      find_cmd="fs -frs wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,uli,idc,decant-api/fc,us-wm-fc,us-wm-manual-fc us-wm-fc.yml,us-wm-manual-fc.yml";;
  esac
      echo "$log [$find_cmd | $search_cmd]"
      eval "$find_cmd" | eval $search_cmd 
}
