pipeline {
    agent any

    // 1️⃣ Parameter for apply/destroy
    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Terraform action: apply or destroy')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        REGION                = 'us-west-1'
        TERRAFORM_DIR         = './'
    }

    stages {

        // 2️⃣ Checkout Code
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Sridevibuji-03/Mini-Terraform-poc.git'
            }
        }

        // 3️⃣ Terraform Init + Apply/Destroy
        stage('Terraform Init & Execute') {
            steps {
                withCredentials([file(credentialsId: 'ec2-private-key', variable: 'PRIVATE_KEY_FILE')]) {
                    script {
                        def PRIVATE_KEY_CONTENT = sh(script: "cat $PRIVATE_KEY_FILE", returnStdout: true).trim()
                        dir("${TERRAFORM_DIR}") {
                            sh 'terraform init -input=false'

                            if (params.ACTION == 'apply') {
                                sh "terraform apply -auto-approve -var 'private_key_content=${PRIVATE_KEY_CONTENT}'"
                            } else if (params.ACTION == 'destroy') {
                                sh "terraform destroy -auto-approve -var 'private_key_content=${PRIVATE_KEY_CONTENT}'"
                            }
                        }
                    }
                }
            }
        }

        // 4️⃣ Verify Outputs (only on apply)
        stage('Verify Outputs') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    def PUBLIC_IP  = sh(script: 'terraform output -raw public_ec2_public_ip', returnStdout: true).trim()
                    def PRIVATE_IP = sh(script: 'terraform output -raw private_ec2_private_ip', returnStdout: true).trim()
                    def S3_BUCKET  = sh(script: 'terraform output -raw s3_bucket_name', returnStdout: true).trim()

                    echo "Public EC2 IP: ${PUBLIC_IP}"
                    echo "Private EC2 IP: ${PRIVATE_IP}"
                    echo "S3 Bucket: ${S3_BUCKET}"
                }
            }
        }

        // 5️⃣ Wait for Private EC2 to upload file (only on apply)
        stage('Wait for Private EC2 to Upload File') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo "Waiting 2 minutes for Private EC2 userdata to upload file..."
                sh 'sleep 120'
            }
        }

        // 6️⃣ Verify S3 Upload (only on apply)
        stage('Verify S3 Upload') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    def bucket = sh(script: 'terraform output -raw s3_bucket_name', returnStdout: true).trim()
                    echo "Checking if test file exists in S3 bucket: ${bucket}"
                    sh "aws s3 ls s3://${bucket}/test-files/"
                }
            }
        }

    }

    post {
        always {
            echo "Pipeline finished for action: ${params.ACTION}"
        }
    }
}
