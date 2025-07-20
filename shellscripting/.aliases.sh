# Aliases for version checking commands
# Add these to your ~/.zshrc file

# UI version - check decant-api, gdm-web with qa,default,stg environments
alias allui='fs -frs decant-api,gdm-web/default-fc,us-wm-fc,us-wm-manual-fc us-wm-manual-fc.yml,us-wm-fc.yml,fc-pre-main-merge.yml,default-fc-stg.yml | search qa,default,stg -s'

# Backend version - check wms-receiving, gdm, os, aos, nte, loading with qa,default environments  
alias allb='fs -frs wms-receiving,gdm,os,aos,nte,loading/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search qa,default -s'

# Individual service aliases
alias rcv='fs -frs wms-receiving/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search qa,default -s'
alias gdm='fs -frs gdm/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search qa,default -s'
alias os='fs -frs os/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search qa,default -s'
alias aos='fs -frs aos/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search qa,default -s'
alias fes='fs -frs nte/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search qa,default -s'
alias loading='fs -frs loading-server/fc,default-fc,us-wm-fc fc-pre-main-merge.yml,us-wm-fc.yml | search qa,default -s'

# Environment specific aliases
alias allqa='fs -frs wms-receiving,gdm,os,aos,nte,loading/fc,us-wm-fc us-wm-fc.yml | search qa -s'
alias alldefault='fs -frs wms-receiving,gdm,os,aos,nte,loading/fc,default-fc fc-pre-main-merge.yml | search default,stg -s'