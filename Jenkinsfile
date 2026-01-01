pipeline {
    agent { label 'docker-tf-ansible' } // Matches your Docker Cloud label
    environment {
        // IDs match what you added in Manage Jenkins > Credentials
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
		stage('Ansible Config') {
				environment {
						// This disables the SSH prompt for the entire stage
						ANSIBLE_HOST_KEY_CHECKING = 'False'
				}
				steps {
						echo "Target IP: ${env.TARGET_IP}"
						// Give the VM a few more seconds to ensure SSH service is fully up
						sleep 30 
						
						ansiblePlaybook(
								playbook: 'ansible/configure.yml',
								inventory: "${env.TARGET_IP},",
								// Use single quotes for the variable name to avoid interpolation warnings
								extraVars: [ 
										ts_key: 'TS_KEY', 
										ansible_user: 'user' 
								]
						)
				}
		}
    }
}
