import json
import sys

d = json.load(sys.stdin)
print(f"Tests : {d['passedTests']}/{d['totalTestCount']} réussis, "
      f"{d['failedTests']} en échec ({d['result']})")
for f in d.get("testFailures", []):
    print(f"  ✗ {f.get('testName')} : {f.get('failureText')}")
