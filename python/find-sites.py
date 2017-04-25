#!/usr/bin/env python

# ----------------------------------------------------------------------
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and/or hardware specification (the "Work") to
# deal in the Work without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Work, and to permit persons to whom the Work
# is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Work.
#
# THE WORK IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE WORK OR THE USE OR OTHER DEALINGS
# IN THE WORK.
# ----------------------------------------------------------------------

# Get floating point division from Python 3
from __future__ import division

import sys

import geni.aggregate.instageni as IG
import geni.util

# For our purposes, all InstaGENI Xen VM servers are equal
# and each can hold a maximum of 43 Xen VMs. This is a
# magic number, don't put too much stock into it. It loosely
# approximates how many VMs a Xen server can hold if they are
# all default sized VMs.
MAX_XEN_LOAD = 43

# Ignore these sites when searching. These are development sites
# or should be ignored for some other reason.
IGNORED_SITE_NAMES = ['ig-utah', 'ig-gpo', 'ig-princeton', 'ig-utahddc']


def get_ad(context, site):
    ad = None
    try:
        ad = site.listresources(context)
    except Exception:
        # Log a notice of some kind?
        # What sorts of exceptions are raised by listresources?
        pass
    return ad


def get_xen_load(ad, site):
    nodes = 0
    site_max = 0
    site_avail = 0
    for node in ad.nodes:
        if not node.exclusive and 'emulab-xen' in node.sliver_types:
            avail = int(node.hardware_types["pcvm"])
            # print 'Site %s: hardware types = %r' % (site.name, what)
            nodes += 1
            site_max += MAX_XEN_LOAD
            site_avail += avail
    # print 'Site %s: Nodes %d; Max VMs %d; avail %d' % (site.name, nodes,
    #                                                    site_max, site_avail)
    # Note this uses __future__ division to get a float from two ints
    score = site_avail / site_max
    # print 'Site score = %r' % (score)
    return score


def available_raw_pcs(ad):
    avail = [node for node in ad.nodes
             if (node.available and node.exclusive and
                 'raw-pc' in node.sliver_types)]
    return len(avail)


def site_cmp(site1, site2):
    if site1.raw_score == site2.raw_score:
        return cmp(site1.xen_score, site2.xen_score)
    else:
        return cmp(site1.raw_score, site2.raw_score)


def main(argv=None):
    if not argv:
        argv = sys.argv
    context = geni.util.loadContext(key_passphrase=True)
    possible_sites = []
    for site in IG.aggregates():
        if site.name in IGNORED_SITE_NAMES:
            continue
        ad = get_ad(context, site)
        if not ad:
            # Site is probably down
            continue
        raw_score = available_raw_pcs(ad)
        if raw_score < 1:
            print 'Skipping %s, no bare metal available.' % (site.name)
            continue
        site.raw_score = raw_score
        site.xen_score = get_xen_load(ad, site)
        possible_sites.append(site)
    print '\n\n-=-=-=-=-=-=-=-=-=-=-\n\n'
    # Sort the best candidates to the front of the list
    possible_sites.sort(cmp=site_cmp, reverse=True)
    for site in possible_sites:
        pretty_xen_score = int(round(site.xen_score * 100))
        print 'Site %s: %d raw, xen score %d)' % (site.name, site.raw_score,
                                                  pretty_xen_score)


if __name__ == '__main__':
    main(sys.argv)
