#!/bin/bash
# Jenkins 构建失败时调用 Hermes AI 诊断桥接服务

BRIDGE_URL="http://172.21.37.181:18992/diagnose"
JENKINS_URL="http://localhost:8080"

# 获取构建日志（最后500行，保留关键错误信息）
LOG_FILE="/tmp/build_${BUILD_NUMBER}_log.txt"
curl -s -u zsh:113243277682f93771ff89e5113e923994 \
  "${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/consoleText" | tail -n 500 > "${LOG_FILE}"

LOG_CONTENT=$(cat "${LOG_FILE}")

# 构建信息
BUILD_INFO=$(cat <<EOF
{
  "number": ${BUILD_NUMBER},
  "job": "${JOB_NAME}",
  "url": "${BUILD_URL}",
  "result": "FAILURE"
}
EOF
)

# 调用桥接服务
RESPONSE=$(curl -s -X POST "${BRIDGE_URL}" \
  -H "Content-Type: application/json" \
  -d "{\"log\": $(echo "${LOG_CONTENT}" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))'), \"build_info\": ${BUILD_INFO}}")

echo "Hermes AI 诊断完成: ${RESPONSE}"

# 清理
rm -f "${LOG_FILE}"
