/**
 * This pipeline will build and deploy a Docker image with Kaniko
 * https://github.com/GoogleContainerTools/kaniko
 * without needing a Docker host
 *
 * You need to create a jenkins-docker-cfg secret with your docker config
 * as described in
 * https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-in-the-cluster-that-holds-your-authorization-token
 */

// https://github.com/jenkinsci/kubernetes-plugin/blob/master/examples/kaniko.groovy
podTemplate(yaml: '''
              kind: Pod
              metadata:
                annotations: {
                  sidecar.istio.io/inject: false
                }
              spec:
                containers:
                - name: kaniko
                  image: gcr.io/kaniko-project/executor:v1.6.0-debug
                  command:
                  - sleep
                  args:
                  - 99d
                - name: kubectl
                  image: bitnami/kubectl:1.22.2
                  securityContext:
                    runAsUser: 0
                  tty: true
                  command:
                  - sleep
                  args:
                  - 99d

'''
  ) {
  node(POD_LABEL) {
    properties([
      pipelineTriggers([[
        $class: 'GenericTrigger',
        token: 'scodex_cd',
        genericVariables: [[key: 'ref', value: '$.ref']],
        regexpFilterText:"\$ref",
        regexpFilterExpression: 'refs/heads/main'
    ]])])
    stage('Build with Kaniko') {
      git branch: 'main', credentialsId: '5640c351-ad51-4440-b828-68d2d04f9b70', url: 'https://github.com/andresirias/devos-training-completo.git'
      container('kaniko') {
        withCredentials([file(credentialsId: 'dockerhub', variable: 'FILE')]) {
          sh 'cp $FILE /kaniko/.docker/config.json'
          sh '/kaniko/executor --dockerfile `pwd`/Dockerfile -c `pwd` --destination=andresirias/page:latest'
        }
      }
    }
    stage('Deploy to kubernetes') {
      git branch: 'main', credentialsId: '5640c351-ad51-4440-b828-68d2d04f9b70', url: 'https://github.com/andresirias/devos-training-completo.git'
      container('kubectl') {
        withCredentials([file(credentialsId: 'kubernetes-config-file', variable: 'FILE')]) {
          sh 'mkdir -p ~/.kube/'
          sh 'cp $FILE ~/.kube/config'
          sh 'kubectl apply -f page.yaml'
          sh 'kubectl label namespace scodex istio-injection=enabled --overwrite'
          sh 'kubectl rollout restart -n scodex deployment/scodex-deployment'
        }
      }
    }
  }
  }
