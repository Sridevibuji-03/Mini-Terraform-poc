pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        REGION                = 'us-west-1'
        TERRAFORM_DIR         = './'
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/yourusername/terraform-mini-project.git'
            }
        }
        stage('Terraform Init & Apply') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        stage('Verify Outputs') {
            steps {
                script {
                    PUBLIC_IP  = sh(script: 'terraform output -raw public_ec2_public_ip', returnStdout: true).trim()
                    PRIVATE_IP = sh(script: 'terraform output -raw private_ec2_private_ip', returnStdout: true).trim()
                    S3_BUCKET  = sh(script: 'terraform output -raw s3_bucket_name', returnStdout: true).trim()
                    echo "Public EC2 IP: ${PUBLIC_IP}"
                    echo "Private EC2 IP: ${PRIVATE_IP}"
                    echo "S3 Bucket: ${S3_BUCKET}"
                }
            }
        }
        stage('Wait for Private EC2 to Upload File') {
            steps {
                echo "Waiting 2 minutes for Private EC2 to run userdata and upload file..."
                sh 'sleep 120'
            }
        }
        stage('Verify S3 Upload') {
            steps {
                echo "Checking if test file exists in S3..."
                sh """
                aws s3 ls s3://$(terraform output -raw s3_bucket_name)/test-files/
                """
            }
        }
    }
    post { 
        always { 
            echo "Pipeline finished successfully." 
        }
    }
} 
