pipeline {
    agent { label 'docker-tf-ansible' } // Matches your Docker Cloud label
    environment {
        // IDs match what you added in Manage Jenkins > Credentials
				TF_VAR_proxmox_api_token = credentials('PVE_CONCAT')
				PVE_TOKEN = credentials('PVE_SECRET')
        TS_KEY    = credentials('TS_AUTHKEY')
    }
    stages {
        stage('Terraform') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh "terraform apply -auto-approve -var='proxmox_api_token=${TF_VAR_proxmox_api_token}'"
                    // Save the IP to an environment variable
                    script {
                        env.TARGET_IP = sh(script: "terraform output -raw vm_ip", returnStdout: true).trim()
                    }
                }
            }
        }
        stage('Ansible') {
            steps {
                echo "Target IP: ${env.TARGET_IP}"
                sh "sleep 60" // Wait for VM to finish booting
                dir('ansible') {
                    ansiblePlaybook(
                        playbook: 'configure.yml',
                        inventory: "${env.TARGET_IP},",
                        extraVars: [ ts_key: "${TS_KEY}" ]
                    )
                }
            }
        }
    }
}
