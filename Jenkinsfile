pipeline {
agent any
environment {
    TF_STATE_BUCKET   = 'demo-project-terraform-app'
    TF_STATE_REGION   = 'ap-southeast-2'
    TF_STATE_KEY      = 'terraform.tfstate'
    TF_VERSION        = '1.15.3'
    TF_WORKING_DIR    = 'environments/prod'
}
stages {
    stage('Install Terraform') {
        steps {
            sh '''
                echo "Installing Terraform..."
                yum install -y unzip
                curl -LO https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
                unzip -o terraform_${TF_VERSION}_linux_amd64.zip
                mv terraform /usr/local/bin/
                terraform version
            '''
        }
    }

    stage('Generate Terraform Variables') {
        steps {
            sh """
                cd ${TF_WORKING_DIR}
                echo "Generating terraform.tfvars from SSM"
                > terraform.tfvars
                for param in \$(aws ssm describe-parameters \
                    --parameter-filters "Key=Name,Option=BeginsWith,Values=/terraform/" \
                    --query "Parameters[*].Name" \
                    --output text); do
                    key=\$(basename \$param)
                    value=\$(aws ssm get-parameter \
                        --name \$param \
                        --with-decryption \
                        --region ${TF_STATE_REGION} \
                        --query "Parameter.Value" \
                        --output text)
                    if [ "\$key" = "allowed_ssh_cidr" ]; then
                        echo "\$key = \$value" >> terraform.tfvars
                    else
                        echo "\$key = \\"\$value\\"" >> terraform.tfvars
                    fi
                    echo "Loaded: \$key"
                done
                cat terraform.tfvars
            """
        }
    }
    stage('Terraform Init') {
        steps {
            sh """
                cd ${TF_WORKING_DIR}

                aws sts get-caller-identity

                rm -rf .terraform
                rm -f .terraform.lock.hcl

                terraform init \
                  -backend-config="bucket=${TF_STATE_BUCKET}" \
                  -backend-config="key=${TF_STATE_KEY}" \
                  -backend-config="region=${TF_STATE_REGION}"
            """
        }
    }
    stage('Terraform Validate') {
        steps {
            sh """
                cd ${TF_WORKING_DIR}
                terraform validate
            """
        }
    }
    stage('Terraform Plan') {
        steps {
            sh """
                cd ${TF_WORKING_DIR}
                terraform plan -var-file=terraform.tfvars
            """
        }
    }
    stage('Terraform Apply') {
        steps {
            sh """
                cd ${TF_WORKING_DIR}
                terraform apply -auto-approve -var-file=terraform.tfvars
            """
        }
    }
}
post {
    success {
        echo 'Terraform deployment completed successfully'
    }
    failure {
        echo 'Terraform deployment failed'
    }
    always {
        archiveArtifacts artifacts: '**/*'
    }
}
}
