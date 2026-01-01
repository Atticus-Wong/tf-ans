pipeline {
    agent { label 'docker-tf-ansible' } // Matches your Docker Cloud label

		parameters {
						string(name: 'VM_NAME', defaultValue: 'debian-tmp', description: 'What should the VM be named?')
				}

    environment {
        // IDs match what you added in Manage Jenkins > Credentials
				TF_VAR_vm_name = "${params.VM_NAME}"
				TF_VAR_proxmox_api_token = credentials('PVE_SECRET')
        TS_KEY    = credentials('TS_AUTHKEY')
				PROXMOX_TOKEN_ID = "terraform-prov@pve!terraform-key"
    }
    stages {
        stage('Terraform') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
										sh 'terraform apply -auto-approve'
                    // Save the IP to an environment variable
                    script {
                        env.TARGET_IP = sh(script: "terraform output -raw vm_ip", returnStdout: true).trim()
                    }
                }
            }
        }
				stage('Ansible') {
						environment {
								ANSIBLE_HOST_KEY_CHECKING = 'False'
						}
						steps {
								// 'my-ssh-key' is the ID of the 'SSH User Private Key' credential
								withCredentials([sshUserPrivateKey(credentialsId: 'AUTOMATION_SSH_KEY', keyFileVariable: 'SSH_KEY')]) {
										sh """
											 ansible-playbook ansible/configure.yml \
											 -i ${env.TARGET_IP}, \
											 --private-key=\$SSH_KEY \
											 -u user \
											 -e "ts_key=${TS_KEY}"
										"""
								}
						}
				}
    }
}
