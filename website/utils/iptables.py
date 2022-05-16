#!/usr/bin/env python
# coding=utf-8

from website.services import exec_command
from flask import current_app
import sys

def save_nat_rule():
    save_rules = 'iptables-save -t nat'
    try:
        with open('/usr/local/flexgw/instance/snat-rules.iptables', 'w') as f:
            results = exec_command(save_rules.split(), stdout=f)
            if results['return_code'] != 0:
                current_app.logger.error('save nat rules failed! %s' % results['stderr'])
                return False
    except:
        current_app.logger.error('[NAT]: exec_command error: %s:%s', save_rules,
                                 sys.exc_info()[1])
        return False
    return True