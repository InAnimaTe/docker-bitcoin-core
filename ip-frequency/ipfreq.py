import os, sys, argparse
from collections import Counter


def collect_ips(log_file):

    ip_addresses = []
    # Let's iterate through each line and make a list of all IPs
    for log_line in log_file:
        line_beginning = log_line.split(" ", 2)
        ip_address = line_beginning[1]
        ip_addresses.append(ip_address)

    return ip_addresses

def ip_occurrence(ip_list):
    ## Utilize Counter() to sort our list into a dict
    ip_occurrences = Counter(ip_list)
    for ip, count in ip_occurrences.most_common():
        print(count, ip)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-f",
        "--logfile",
        required=True,
        help="The logfile to determine IP frequency"
    )

    args = parser.parse_args()

    log_file = open(args.logfile)

    ip_list = collect_ips(log_file)

    ip_occurrence(ip_list)

if __name__ == "__main__":
    main()