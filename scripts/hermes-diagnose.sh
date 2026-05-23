#!/bin/bash
# Jenkins 构建失败时调用 Hermes AI 诊断桥接服务

BRIDGE_URL="http://172.21.37.181:18992/diagnose"
JENKINS_URL="http://localhost:8080"

# 获取完整日志，然后精确提取错误信息
FULL_LOG=$(curl -s -u zsh:113243277682f93771ff89e5113e923994 \
  "${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/consoleText")

# 精确筛选：错误行 + 构建失败标志 + 关键异常
ERROR_LINES=$(echo "${FULL_LOG}" | grep -E "\[ERROR\]|BUILD FAILURE|Compilation failure|cannot find symbol|Execution Failed|script returned exit code" | tail -50)

# 如果没找到 ERROR，再尝试提取最后 100 行作为兜底
if [ -z "${ERROR_LINES}" ]; then
    ERROR_LINES=$(echo "${FULL_LOG}" | tail -100)
fi

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

# 调用桥接服务（只发错误行，不是全部日志）
RESPONSE=$(curl -s -X POST "${BRIDGE_URL}" \
  -H "Content-Type: application/json" \
  -d "{\"log\": $(echo "${ERROR_LINES}" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))'), \"build_info\": ${BUILD_INFO}}")

echo "Hermes AI 诊断完成: ${RESPONSE}"
