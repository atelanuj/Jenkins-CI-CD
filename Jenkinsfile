//@Library('jenkins-shared-library1-singham@main') _
//comment
pipeline {
    agent any

    tools {
        maven 'myMaven'
    }

    parameters {
    string(name: 'ImageName', description: "Name of the docker build", defaultValue: "kubernetes-configmap-reload")
    string(name: 'ImageTag', description: "Name of the docker build", defaultValue: "v${BUILD_NUMBER}")
    string(name: 'AppName', description: "Name of the Application", defaultValue: "kubernetes-configmap-reload")
    string(name: 'docker_repo', description: "Name of docker repository", defaultValue: "anujatel")
    string(name: 'eks_cluster_name', description: "Name of Kubernetes Cluster", defaultValue: "my-eks-cluster")
    string(name: 'region_code', description: "AWS Cluster Region", defaultValue: "ap-south-1")
  }

    stages{
        stage("git-CheckOut"){
            steps{
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/atelanuj/Jenkins-CI-CD.git']])
            }
        }

        stage("Maven-Build"){
            steps{
               
                    sh 'mvn clean package'
                
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
        stage("Docker-image-Build"){
            steps{
                
                    sh 'docker build -t ${docker_repo}/${ImageName}:${ImageTag} .'
                
            }
        }

        stage("Docker-Push"){
            steps{
                
                    script{
                        /*withCredentials([string(credentialsId: 'DockerHubPasswd', variable: 'passwd')]) {
                         	sh 'docker login -u $docker_cred -p $passwd'
                        }*/
                        sh 'docker push $docker_repo/$ImageName:$ImageTag'
                    }
                
            }
        }

        stage("EKS-Deployment"){
            steps{
                sh 'echo ${WORKSPACE}'
		        sh 'aws eks update-kubeconfig --region ${region_code} --name ${eks_cluster_name}' //kubeconfig update
                sh 'kubectl create ns ${AppName}'  //namespace created
                sh 'kubectl apply -f ${WORKSPACE}/Deployment.yaml'
                sh 'sleep 10'
                sh 'kubectl get all -n ${AppName}'
            }
        }
    }
}
