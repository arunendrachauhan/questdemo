def gitUrl = 'https://github.com/codecentric/conference-app'

createPipelineJob ("MyDemo", gitUrl, "jenkins/Jenkinsfile")
def createPipelineJob (def jobName, def gitUrl, def scriptPath){
pipelineJob("${jobName}") {
	description()
	keepDependencies(false)
	definition {
		cpsScm {
			scm {
				git {
					remote {
						github(gitUrl, "https")

					}
					branch("*/master")
				}
			}
			scriptPath(scriptPath)
		}
	}
	disabled(false)
	configure {
		it / 'properties' / 'com.coravy.hudson.plugins.github.GithubProjectProperty' {
			'projectUrl'('https://github.globant.com/arunendra-chauhan/devopsquest4.git/')
			displayName("DEMO")
		}
	}
}
