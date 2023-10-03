.PHONY: start stop shutdown restart clean

PORT ?= 8888
NETWORK ?= Wi-Fi

PROXY_HOST ?= 127.0.0.1
PROXY_PORT ?= 8088
PROXY_ADDRESS := $(PROXY_HOST):$(PROXY_PORT)

start:
SESSION ?= $(CURDIR)/app_debugging
OWASP_ZAP := /Applications/OWASP\ ZAP.app
RUN_ZAP_COMMAND := open $(OWASP_ZAP) --args
# Start a new session or use existing session
ifneq "$(wildcard $(SESSION))" ""
# Given session is an existing file
RUN_ZAP_COMMAND += -session "$(SESSION)"
else
# Try session with given name in current directory
SESSION_PATH = $(abspath $(SESSION).session)
ifeq "$(wildcard $(SESSION_PATH))" ""
RUN_ZAP_COMMAND += -newsession "$(SESSION_PATH)"
else
RUN_ZAP_COMMAND += -session "$(SESSION_PATH)"
endif
endif
SPECIFIED := environment, command line
ifneq "$(findstring $(origin PROXY_HOST), $(SPECIFIED))" ""
RUN_ZAP_COMMAND += -host $(PROXY_HOST)
endif
ifneq "$(findstring $(origin PROXY_PORT), $(SPECIFIED))" ""
RUN_ZAP_COMMAND += -port $(PROXY_PORT)
endif

start: debugging.pac zap.pid server.pid

stop:
	@networksetup -setautoproxystate "$(NETWORK)" off

shutdown: stop
	@if test -e zap.pid; then \
	   read PID<zap.pid; \
	   kill $${PID} 2>/dev/null && rm zap.pid || echo "Failed to close ZAP (pid = $${PID})" >&2; \
	   PID=`$(runningzap)`; \
	   echo "Trying again with running ZAP (pid = $${PID})" >&2; \
	   kill $${PID} 2>/dev/null && rm zap.pid; \
	 else \
	   kill `$(runningzap)` 2>/dev/null; \
	 fi; unset -v PID
	@if test -e server.pid; then \
	   read PID<server.pid; \
	   kill $${PID} 2>/dev/null && rm server.pid || echo "Failed to stop server (pid = $${PID})" >&2; \
	 fi; unset -v PID

restart: shutdown start
	
clean: shutdown
	@rm debugging.pac

debugging.pac: urls.conf
	@echo "function FindProxyForURL(url, host) {" > debugging.pac; \
	 while read url; do \
	   echo "  if (shExpMatch(host, \"$${url}\")) { return \"PROXY $(PROXY_ADDRESS)\"; }" >> debugging.pac; \
	 done <urls.conf; \
	 echo "  return \"DIRECT\";\n}" >> debugging.pac

urls.conf:
	@echo "Enter url patterns to proxy (leave out scheme; * can be used as a wildcard),\n\
	one entry per line, terminating with a blank line:"
	@while read -r url && test "$${url}"; do echo "$${url}" >> urls.conf; done

zap.pid:
	@if test ! -e zap.pid; then $(RUN_ZAP_COMMAND); fi && \
	 $(runningzap) > "zap.pid"

server.pid:
	@python3 -m http.server $(PORT) --bind 127.0.0.1 2>/dev/null & echo $$! > server.pid
	@networksetup -setautoproxyurl "$(NETWORK)" http://127.0.0.1:$(PORT)/debugging.pac

define runningzap
ps -Ao pid=,command= | grep -m1 ${OWASP_ZAP} | awk '{print $$1}'
endef