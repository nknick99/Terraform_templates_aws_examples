// Jenkinsfile
pipeline {
    agent any

    environment {
        TERRAFORM_VERSION = "1.5.0" // Adjust to your Terraform version
        PRISMA_CLI = "/path/to/prisma-cloud-iac-scan" // Update with the actual Prisma CLI path
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Prisma Cloud IaC Scan') {
            steps {
                script {
                    def scanResult = sh(script: "${PRISMA_CLI} --tf-plan-json terraform.tfplan", returnStatus: true)
                    if (scanResult != 0) {
                        error("Prisma Cloud IaC scan failed. Fix the misconfigurations before proceeding.")
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=terraform.tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve terraform.tfplan'
            }
        }

        stage('Wait for 5 Minutes') {
            steps {
                script {
                    sleep(time: 5, unit: 'MINUTES')
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                sh 'terraform destroy -auto-approve'
            }
        }
    }

    post {
        always {
            cleanWs() // Clean up the workspace
        }
    }
}