//@Library('jenkins-shared-library1-singham@main') _
pipeline {
    agent any

    tools {
        maven 'myMaven'
    }

    parameters {
	choice(name: 'action', choices: 'create\nrollback', description: 'Create/rollback of the deployment')
    string(name: 'ImageName', description: "Name of the docker build", defaultValue: "kubernetes-configmap-reload")
	string(name: 'ImageTag', description: "Name of the docker build", defaultValue: "v${BUILD_NUMBER}")
	string(name: 'AppName', description: "Name of the Application", defaultValue: "kubernetes-configmap-reload")
    string(name: 'docker_repo', description: "Name of docker repository", defaultValue: "anujatel")
    string(name: 'eks-cluster-name', description: "Name of Kubernetes Cluster", defaultValue: "my-eks-cluster")
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
                dir("${params.AppName}") {
                    sh 'ls -lrt'
                    sh 'mvn clean package'
                }
            }
        }
/*
        stage("Jfrog-deploy"){

        }
*/
        stage("Docker-image-Build"){
            when{
                expression {params.action == 'create'}
            }
            steps{
                dir("${params.AppName}"){
                    sh 'docker build -t ${docker_repo}/${ImageName}:${ImageTag} .'
                }
            }
        }

        stage("Docker-Push"){
            when{
                expression {params.action == 'create'}
            }
            steps{
                dir("${params.AppName}"){
                    script{
                        // withCredentials([string(credentialsId: 'DockerHubPasswd', variable: 'passwd')]) {
                        // sh 'docker login -u $docker_cred -p $passwd'
                        // }
                        sh 'docker push $docker_repo/$ImageName:$ImageTag'
                    }
                }
            }
        }
/*
        stage("Docker-CLeanUP-Images"){
            when{
                expression {params.action == 'create'}
            }
            steps{
                sh 'docker rmi $docker_repo/$ImageName:$ImageTag'
                sh 'docker image prune'
            }
        }

        stage("Ansible-Setup"){
            when {
				expression { params.action == 'create' }
			}
            steps{
                dir("${params.AppName}"){
                    sh 'ansible-playbook ${WORKSPACE}/${AppName}/ansible-playbook.yaml'
                }
            }
        }
*/
        stage("EKS Cluster Creation upto 20 mins"){
            when {
				expression { params.action == 'create' }
			}
            steps{
                dir("${params.AppName}"){
                    sh 'eksctl create cluster -f eksctl.yaml'
                }
            }
        }

        stage("EKS-Deployment"){
            when {
				expression { params.action == 'create' }
			}
            steps{
                sh 'echo ${WORKSPACE}'
                sh 'kubectl create ns ${params.AppName}'  //namespace created
                sh 'kubectl apply -f ${WORKSPACE}/kubernetes-configmap-reload/Deployment.yaml'
                sh 'sleep 10'
                sh 'kubectl get all -n ${params.AppName}'
            }
        }

        stage("Wait for Pod-Creation"){
            when {
				expression { params.action == 'create' }
			}
            steps{
                sh 'sleep 100'
            }
        }

        stage("Roll-Back-Deployment"){
            steps{
                dir("${params.AppName}"){
                    sh 'kubectl delete deploy -n ${params.AppName} ${params.AppName}'
                    sh 'kubectl delete svc -n ${params.AppName} ${params.AppName}'
                }
            }
        }

        stage("Deleting the EKS Cluster upto 15 min"){
            steps{
                sh 'eksctl delete cluster --name ${params.eks-cluster-name}'
            }
        }

    }
}