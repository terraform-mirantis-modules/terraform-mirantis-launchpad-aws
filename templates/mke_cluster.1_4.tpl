apiVersion: launchpad.mirantis.com/mke/v1.4
kind: %{ if msr_count > 0 }mke+msr%{ else }mke%{ endif }

metadata:
  name: ${cluster_name}

spec:
  hosts:
%{ for host in hosts ~}

  - role: ${host.role}
  %{ if can( host.ssh ) }
    ssh:
      address: ${host.ssh.address}
      user: ${host.ssh.user}
      keyPath: ${key_path}
  %{ endif ~}
  %{ if can( host.winrm ) }
    winRM:
      address: ${host.winrm.address}
      user: ${host.winrm.user}
      password: ${host.winrm.password}
      useHTTPS: ${host.winrm.useHTTPS}
      insecure: ${host.winrm.insecure}
  %{ endif ~}

  %{ if can( host.hooks ) }
    hooks:
      apply:
    %{ if can( host.hooks.apply.before ) }
        before: %{ for hook in host.hooks.apply.before }
        - "${hook}"%{ endfor }
    %{ endif ~}
    %{ if can( host.hooks.apply.after) }
        after: %{ for hook in host.hooks.apply.after }
        - "${hook}"%{ endfor }
    %{ endif ~}
  %{ endif ~}
%{ endfor ~}

  mcr:
    version: ${mcr_version}
    repoURL: ${mcr_repoURL}
    channel: ${mcr_channel}
    installURLLinux: ${mcr_installURLLinux}
    installURLWindows: ${mcr_installURLWindows}

  mke:
    version: ${mke_version}
    imageRepo: ${mke_image_repo}
    adminUsername: ${mke_admin_username}
    adminPassword: ${mke_admin_password}
    installFlags:
    - "--san=${mke_san}"
    %{ if mke_kube_orchestration }- "--default-node-orchestrator=kubernetes"%{ endif }
    %{ for installFlag in mke_installFlags }
    - "${installFlag}"%{ endfor ~}

    upgradeFlags:
    %{ for upgradeFlag in mke_upgradeFlags }
    - "${upgradeFlag}"%{ endfor ~}

  msr:
    version: ${msr_version}
    imageRepo: ${msr_image_repo}
    installFlags:
    %{ for installFlag in msr_installFlags }
    - "${installFlag}"%{ endfor ~}
    %{ if msr_nfs_storage_url != "" }
    -  "--nfs-options nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport"
    - "--nfs-storage-url nfs://${msr_nfs_storage_url}/"
    %{ else }
    # No EFS/NFS configured
    %{ endif }

    replicaIDs: ${msr_replica_config}

  cluster:
    prune: %{ if cluster_prune }true%{ else }false%{ endif }

%{ if msr_nfs_storage_url != "" }
# To troubleshoot EFS via NFS:  Login to a node, then as root:
# mkdir /mnt/efs
# mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${msr_nfs_storage_url}:/ /mnt/efs
%{ else }
# No EFS/NFS configured
%{ endif }