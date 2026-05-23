#!/bin/bash
# Jenkins 构建失败时调用 Hermes AI 诊断桥接服务

BRIDGE_URL="http://172.21.37.181:18992/diagnose"
JENKINS_URL="http://localhost:8080"

# 获取完整日志
FULL_LOG=$(curl -s -u zsh:113243277682f93771ff89e5113e923994 \
  "${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/consoleText")

# 策略：从后往前找到 BUILD FAILURE 所在行，然后提取该行 + 前20行（包含真正的错误上下文）
# 这样确保抓到真正的失败原因，而不是被前面的下载进度干扰
CONTEXT_LINES=$(echo "${FULL_LOG}" | tail -200 | grep -n "BUILD FAILURE\|BUILD SUCCESS\|Finished:" | head -1 | cut -d: -f1)

if [ -n "${CONTEXT_LINES}" ]; then
    # 找到了 BUILD FAILURE，取其前面的关键错误信息
    ERROR_CONTEXT=$(echo "${FULL_LOG}" | tail -200 | head -n $((CONTEXT_LINES + 20)) | grep -E "ERROR|FAILURE|Error|Failed|cannot find|symbol:|location:" | head -20)
else
    # 兜底：直接取最后100行中的错误
    ERROR_CONTEXT=$(echo "${FULL_LOG}" | tail -100 | grep -E "ERROR|FAILURE|Error|Failed|cannot find|symbol:|location:" | head -20)
fi

# 如果还是没提取到，取最后50行作为兜底
if [ -z "${ERROR_CONTEXT}" ]; then
    ERROR_CONTEXT=$(echo "${FULL_LOG}" | tail -50)
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

# 调用桥接服务
RESPONSE=$(curl -s -X POST "${BRIDGE_URL}" \
  -H "Content-Type: application/json" \
  -d "{\"log\": $(echo "${ERROR_CONTEXT}" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))'), \"build_info\": ${BUILD_INFO}}")

echo "Hermes AI 诊断完成: ${RESPONSE}"
