///
pipeline{
    agent any
    //  parameters {
    //      string(name: 'FE_S3_Bucket', defaultValue: 'stanislav.tiab.tech.s3.amazonaws.com')
    //      string(name: 'CF_DIST_ID', defaultValue: '')
    //  }
    environment {
        FE_S3_Bucket = 'hw22russu'
        CF_DIST_ID = 'E2UUFZPV43ALFK'
        BACKEND_ENTRYPOINT = 'https://api.stanislav.tiab.tech/api'
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
                contentReplace(
                    configs: [ 
                        fileContentReplaceConfig( 
                            configs: [ 
                                fileContentReplaceItemConfig( 
                                    search: "BACKEND_ENDPOINT_VARIABLE",
                                    replace: "${env.BACKEND_ENDPOINT}",
                                    matchCount: 1
                                )
                            ],
                            fileEncoding: 'UTF-8',
                            filePath: './src/agent.js'
                        ) 
                    ]
                )                                 
                sh 'npm install'
                sh 'npm run build'
            }
        }
        stage("Deploy") {
            environment {
                AWS_DEFAULT_REGION = 'us-east-1'
            }
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
                       sh """
                       aws s3 sync ./build/ s3://${env.FE_S3_Bucket}/
                       aws cloudfront create-invalidation --distribution-id ${env.CF_DIST_ID} --paths "/*"
                       """
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
