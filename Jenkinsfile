pipeline {
    agent any
    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Terraform action')
        choice(name: 'ENV', choices: ['dev', 'prod'], description: 'Environment')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        REGION                = 'us-west-1'
        TERRAFORM_DIR         = './'
    }
    stages {
        stage('Checkout') {
            steps { git branch: 'main', url: 'https://github.com/Sridevibuji-03/Mini-Terraform-poc.git' }
        }
        stage('Terraform Action') {
            steps {
                withCredentials([file(credentialsId: 'ec2-private-key', variable: 'PRIVATE_KEY_FILE')]) {
                    script {
                        sh """
                        terraform init -input=false
                        terraform ${params.ACTION} -auto-approve -var "env=${params.ENV}" -var "private_key_content=$(cat $PRIVATE_KEY_FILE)"
                        """
                    }
                }
            }
        }
        stage('Verify Outputs') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                script {
                    def outputs = [
                        PUBLIC_IP: sh(script:'terraform output -raw public_ec2_public_ip', returnStdout:true).trim(),
                        PRIVATE_IP: sh(script:'terraform output -raw private_ec2_private_ip', returnStdout:true).trim(),
                        S3_BUCKET: sh(script:'terraform output -raw s3_bucket_name', returnStdout:true).trim()
                    ]
                    echo "Outputs: ${outputs}"

                    // Wait for S3 file with retry
                    def maxRetries = 10
                    def count = 0
                    while (count < maxRetries) {
                        def result = sh(script: "aws s3 ls s3://${outputs.S3_BUCKET}/test-files/ || echo 'Not yet'", returnStdout: true).trim()
                        if (!result.contains('Not yet')) { echo "File found!"; break }
                        echo "Waiting for S3 file... retry ${count + 1}/${maxRetries}"
                        sleep(15); count++
                    }
                    if (count == maxRetries) error "S3 file not found after retries!"
                }
            }
        }
    }
    post { always { echo "Pipeline finished for action: ${params.ACTION}" } }
}
