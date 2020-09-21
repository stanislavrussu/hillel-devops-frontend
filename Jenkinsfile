/// FRONTEND
pipeline{
    agent any
/// parameters {
///     string(name: 'FE_S3_Bucket', defaultValue: '', description: 'S3 bucket with frontend content')
///     string(name: 'CF_DIST_ID', defaultValue: '', description: 'CloudFront Distribution ID')
///     string(name: 'BACKEND_ENDPOINT', defaultValue: '', description: 'API endpoint URL')
/// }
/// environment {
///     FE_S3_Bucket = 'hw22russu'
///     CF_DIST_ID = 'E2QXCM6XYO1ZQQ'
///     BACKEND_ENTRYPOINT = 'https://api.stanislav.tiab.tech/api'
/// }
    environment {
        AWS_DEFAULT_REGION = 'es-east-1'
    }
    stages{
        stage("Build") {
            agent {
                docker { 
                    image 'node:12'
                    reuseNode true
                }
            }
            steps {
                withAWSParameterStore(
                            credentialsId: 'aws_creds',
                            naming: 'basename',
                            path: "/${env.BRANCH_NAME}",
                            regionName: "${env.AWS_DEFAULT_REGION}"
                        ){
                            sh 'env'
                            contentReplace(
                                configs: [ 
                                    fileContentReplaceConfig( 
                                        configs: [ 
                                            fileContentReplaceItemConfig( 
                                                search: "BACKEND_ENDPOINT_VARIABLE",
                                                replace: "${env.BACKEND_ENDPOINT_VARIABLE}",
                                                matchCount: 1
                                            )
                                        ],
                                        fileEncoding: 'UTF-8',
                                        filePath: './src/agent.js'
                                    ) 
                                ]
                            )
                        }              
                sh 'npm install'
                sh 'npm run build'
            }
        }
        stage("Deploy") {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    reuseNode true
                    args '--entrypoint=""'
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    credentialsId: 'aws_creds',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                        withAWSParameterStore(
                            credentialsId: 'aws_creds',
                            naming: 'basename',
                            path: "/${env.BRANCH_NAME}",
                            regionName: "${env.AWS_DEFAULT_REGION}"
                        ) {
                        sh """
                            env
                            aws s3 sync ./build/ s3://${env.FE_S3_Bucket}/
                            aws cloudfront create-invalidation --distribution-id ${env.CF_DIST_ID} --paths "/*"
                        """
                        }
                    }
            }
        }
    }
    post{
        always{
            cleanWs()
        }
    }
}
