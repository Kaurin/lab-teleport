
#### Local server
 * Download VHD - https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022
 * sudo qemu-img convert -f vpc -O qcow2 ~/Downloads/17763.737.amd64fre.rs5_release_svc_refresh.190906-2324_server_serverdatacentereval_en-us_1.vhd /var/lib/libvirt/images/WinServer2019-win1.qcow2
 * sudo qemu-img convert -f vpc -O qcow2 ~/Downloads/17763.737.amd64fre.rs5_release_svc_refresh.190906-2324_server_serverdatacentereval_en-us_1.vhd /var/lib/libvirt/images/WinServer2019-win2.qcow2
 * hostname - change to win1,win2... then restart
 * Optional (don't bother): virtio-win - https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md
 * Static IP
 * Install AD adnd promote WIN1 to a domain controller: https://petri.com/how-to-install-active-directory-in-windows-server-2019-server-manager/
 * Join win2 to win1 DC: https://msftwebcast.com/2019/04/join-windows-server-2019-to-an-existing-active-directory-domain.html
 * Enable RDP on WIN1 in local server settings

#### Teleport
Set up on the linux host
https://goteleport.com/docs/desktop-access/active-directory/
NOTE: When windows spits out the yaml, you can just use the windows_desktop_service yaml block but will have to add `windows_desktop_service.listen_addr`
Set up Windows RBAC
https://goteleport.com/docs/desktop-access/rbac/


#### 2022

```
sudo qemu-img convert -f vpc -O qcow2 ~/Downloads/20348.169.amd64fre.fe_release_svc_refresh.210806-2348_server_serverdatacentereval_en-us.vhd /var/lib/libvirt/images/WinServer2022-win1.qcow2
sudo qemu-img convert -f vpc -O qcow2 ~/Downloads/20348.169.amd64fre.fe_release_svc_refresh.210806-2348_server_serverdatacentereval_en-us.vhd /var/lib/libvirt/images/WinServer2022-win2.qcow2
```


Win2k22 DC: https://petri.com/windows-server-2022-as-a-domain-controller/
How to add a Win server as a DC to an existing domain: https://xpertstec.com/microsoft/microsoft-windows-server/windows-server-2022/how-to-install-additional-domain-controller-server-2022/

