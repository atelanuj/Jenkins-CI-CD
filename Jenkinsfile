@Library('jenkins-shared-library1-singham@main') _
pipeline {
    agent any

    tools {
        maven 'myMaven'
    }

    parameters {
	choice(name: 'action', choices: 'create\nrollback', description: 'Create/rollback of the deployment')
    string(name: 'ImageName', description: "Name of the docker build", defaultValue: "kubernetes-configmap-reload")
	string(name: 'ImageTag', description: "Name of the docker build",defaultValue: "v${BUILD_NUMBER}")
	string(name: 'AppName', description: "Name of the Application",defaultValue: "kubernetes-configmap-reload")
    string(name: 'docker_repo', description: "Name of docker repository",defaultValue: "anujatel")
  }

    stages{
        stage("git-CheckOut"){
            steps{
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/atelanuj/spring-cloud-kubernetes-singham-2-ci-cd.git']])
            }
        }
/*
        stage("SonarQube-Static Code Analysis"){
            steps{
                 script{
                     withSonarQubeEnv(credentialsId: 'SonarToken') {
                        sh 'mvn sonar:sonar'
                    }
                     timeout(time: 1, unit: 'HOURS') {                                 //qualitGate is true then the rest will run else false
                        waitForQualityGate abortPipeline: true, credentialsId: 'SonarToken'
                    }
                 }
             }
        }
*/
        stage("Maven-Build"){
            when{
                expression {params.action == 'create'}
            }
            steps{
                sh 'ls -lrt'
                sh 'mvn clean package'
            }
        }
/*
        stage("Nexus-deploy"){

        }
*/
        stage("Docker-Build"){
            when{
                expression {params.action == 'create'}
            }
            steps{
                dockerbuild ("${params.ImageName}", "${params.docker_repo}")
            }
        }

        stage("Docker-Push"){
            when{
                expression {params.action == 'create'}
            }
            steps{
                dockerbuild ("${params.ImageName}", "${params.docker_repo}")
            }
        }

        stage("Docker-CLeanUP-Images"){
            when{
                expression {params.action == 'create'}
            }
            steps{
                dockerCLeanUP ("${params.ImageName}", "${params.docker_repo}")
            }
        }
/*
        stage("Ansible-Setup"){
            when {
				expression { params.action == 'create' }
			}
            steps{
                sh 'ansible-playbook ${WORKSPACE}/ansible-playbook.yaml'
            }
        }
*/
        stage("EKS/MINIkube-Deployment"){
            when {
				expression { params.action == 'create' }
			}
            steps{
                sh 'echo ${WORKSPACE}'
                sh 'kubectl apply -f ${WORKSPACE}/kubernetes-configmap-reload/Deployment.yaml'
                script{
                    kubernetesDeploy (configs: 'Deployment.yaml', kubeconfigId: 'MiniKube')
                }
            }
        }

        stage("Wait for Pod-Creation"){
            steps{
                sh 'sleep 200'
            }
        }
/*
        stage("Roll-Back-Deployment"){
            steps{
                sh 'kubectl delete deploy ${params.AppName}'
                sh 'kubectl delete svc ${params.AppName}'
            }
        }
*/
    }
}