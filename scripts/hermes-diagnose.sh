#!/bin/bash
echo "=============================="
echo "Hermes 诊断已触发"
echo "=============================="
echo "构建链接: $BUILD_URL"
echo ""
echo "错误日志摘要："
# 暂时只打印最后50行日志，等 Hermes 装好后再替换为真实分析命令
tail -n 50 "$JENKINS_HOME/jobs/$JOB_NAME/builds/$BUILD_NUMBER/log"
echo ""
echo "=============================="
echo "提示：后续这里会调用 hermes CLI 进行智能分析"