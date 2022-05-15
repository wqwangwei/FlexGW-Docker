#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    user-manage
    ~~~~~~~~~~~~

    flexgw account manage scripts.
"""


from itertools import count
import os
import re
import sys
import sqlite3
from unittest import case


DATABASE = '%s/instance/website.db' % os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir))


def __query_db(query, args=(), one=False):
    conn = sqlite3.connect(DATABASE)
    cur = conn.cursor()
    cur.row_factory = sqlite3.Row
    cur = cur.execute(query, args)
    conn.commit()
    cur.close()
    conn.close()


def _insert(name):
    regex = re.compile(r'^[\w]+$', 0)
    if not regex.match(name):
        sys.exit(1)
    __query_db("insert into user_details values(?,'',0,?)", [name,'en'])
    sys.exit(0)


if __name__ == '__main__':
    case    = sys.argv[1] if  len( sys.argv)>2 else 'help'
    if case == 'add':
        name = sys.argv[2]
        _insert(name)
    else:    
        sys.exit(1)