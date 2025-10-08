pipeline {
    agent any

    parameters {
        choice(name: 'TF_ACTION', choices: ['apply', 'destroy'], description: 'Select Terraform Action')
        choice(name: 'DEPLOY_ENV', choices: ['dev', 'prod'], description: 'Select Environment')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        AWS_REGION            = 'us-west-1'
        TERRAFORM_DIR         = './'
    }

    stages {

        stage('Checkout Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Sridevibuji-03/Mini-Terraform-poc.git'
            }
        }

        stage('Terraform Initialization') {
            steps {
                dir("${env.TERRAFORM_DIR}") {
                    sh '''
                        echo "📦 Initializing Terraform..."
                        terraform init -input=false
                        terraform validate
                    '''
                }
            }
        }

        stage('Terraform Execution') {
            steps {
                withCredentials([file(credentialsId: 'ec2-private-key', variable: 'PRIVATE_KEY')]) {
                    dir("${env.TERRAFORM_DIR}") {
                        sh '''
                            echo "🚀 Running Terraform ${TF_ACTION} for ${DEPLOY_ENV}..."
                            terraform ${TF_ACTION} -auto-approve \
                              -var="env=${DEPLOY_ENV}" \
                              -var="private_key_content=$(cat ${PRIVATE_KEY})"
                        '''
                    }
                }
            }
        }

        stage('Verify S3 Upload') {
            when { expression { params.TF_ACTION == 'apply' } }
            steps {
                script {
                    echo "🔍 Checking Terraform outputs..."
                    def publicIP  = sh(script: "terraform output -raw public_ec2_public_ip", returnStdout: true).trim()
                    def privateIP = sh(script: "terraform output -raw private_ec2_private_ip", returnStdout: true).trim()
                    def bucket    = sh(script: "terraform output -raw s3_bucket_name", returnStdout: true).trim()

                    echo """
                    🌐 Public IP:  ${publicIP}
                    🔒 Private IP: ${privateIP}
                    🪣 S3 Bucket:  ${bucket}
                    """

                    echo "⏳ Waiting for S3 test file to appear..."
                    retry(8) {
                        def check = sh(script: "aws s3 ls s3://${bucket}/test-files/ || echo 'Not ready'", returnStdout: true).trim()
                        if (check.contains("Not ready")) {
                            echo "File not found yet... retrying in 15s"
                            sleep(15)
                            error("retry")
                        } else {
                            echo "✅ Test file detected in S3 bucket!"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo "🏁 Pipeline completed for ${params.TF_ACTION} in ${params.DEPLOY_ENV} environment."
        }
    }
}
