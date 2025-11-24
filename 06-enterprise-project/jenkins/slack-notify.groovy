def call(String message, String color = "good") {

    // Default Slack color mapping
    def slackColor = color ?: "good"

    slackSend(
        channel: "#devops-alerts",
        color: slackColor,
        message: """
*${message}*

*Job:* ${env.JOB_NAME}
*Build:* #${env.BUILD_NUMBER}
*Status:* ${currentBuild.currentResult}
*Author:* ${env.GIT_AUTHOR_NAME}
*Branch:* ${env.GIT_BRANCH}
*URL:* ${env.BUILD_URL}
"""
    )
}

