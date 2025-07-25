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
# Individual service aliases
alias rcv='fs -frs wms-receiving/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search -s'
alias gdm='fs -frs gdm/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search -s'
alias inv='fs -fr isc/us-wm-fc,default-fc us-wm-fc.yml,pre-main.yml | ss -s'
alias os='fs -frs os/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search -s'
alias aos='fs -frs aos/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search -s'
alias fes='fs -frs nte/default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search -s'
alias loading='fs -frs loading-server/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search -s'


function vp() {
  case "$1" in
    i)
      echo "fs -frs wms-receiving,gdm,os,aos,nte,loading,isc,uli/fc,us-wm-fc us-wm-fc.yml | ss $2 -s"
      fs -frs wms-receiving,gdm,isc,slotting,uwms-location/fc,us-wm-fc us-wm-fc.yml | ss $2 -s;;
    o)
      echo "fs -frs os,aos,nte,loading,isc/fc,us-wm-fc us-wm-fc.yml | ss $2 -s"
      fs -frs os,aos,nte,loading,uli/fc,us-wm-fc us-wm-fc.yml | ss $2 -s;;
    ui)
      echo "fs -frs gdm-web,idc,decant-api/us-wm-fc,us-wm-manual-fc us-wm-manual-fc.yml,us-wm-fc.yml | ss $2 -s"
      fs -frs gdm-web,idc,decant-api/us-wm-fc,us-wm-manual-fc us-wm-manual-fc.yml,us-wm-fc.yml | ss $2 -s ;;
    io)
      echo "fs -frs wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,isc,uli/fc,us-wm-fc us-wm-fc.yml | ss $2 -s"
            fs -frs wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,isc,uli/fc,us-wm-fc us-wm-fc.yml | ss $2 -s;;
    ioui)
      echo "fs -frs wms-receiving,gdm,os,aos,nte,loading,isc,uli,idc,decant-api/fc,us-wm-fc,us-wm-manual-fc us-wm-fc.yml,us-wm-manual-fc.yml | ss $2 -s"
      fs -frs wms-receiving,gdm,isc,slotting,uwms-location,os,aos,nte,loading,uli,idc,decant-api/fc,us-wm-fc,us-wm-manual-fc us-wm-fc.yml,us-wm-manual-fc.yml | ss $2 -s;;
    *)
      echo "Usage: vp {i|o|ui|io|ioui} <arg>"
      return 1
      ;;
  esac
}
