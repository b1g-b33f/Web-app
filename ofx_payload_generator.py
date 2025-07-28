import datetime
import uuid
from pathlib import Path

def generate_ofx(account_id, transactions, output_file="test.ofx"):
    now = datetime.datetime.now()
    dtserver = now.strftime("%Y%m%d%H%M%S") + ".000[-7:MST]"
    dtstart = (now - datetime.timedelta(days=30)).strftime("%Y%m%d050000.000[-7:MST]")
    dtend = now.strftime("%Y%m%d050000.000[-7:MST]")

    header = (
        "OFXHEADER:100\n"
        "DATA:OFXSGML\n"
        "VERSION:102\n"
        "SECURITY:NONE\n"
        "ENCODING:USASCII\n"
        "CHARSET:1252\n"
        "COMPRESSION:NONE\n"
        "OLDFILEUID:NONE\n"
        "NEWFILEUID:NONE\n\n"
    )

    signon = f"""<OFX>
    <SIGNONMSGSRSV1>
        <SONRS>
            <STATUS>
                <CODE>0
                <SEVERITY>INFO
                <MESSAGE>Login successful
            </STATUS>
            <DTSERVER>{dtserver}
            <LANGUAGE>ENG
            <FI>
                <ORG>AMEX
                <FID>3101
            </FI>
            <ORIGIN.ID>FMPWeb
            <INTU.BID>3101
            <START.TIME>{dtserver}
            <INTU.USERID>pentester
        </SONRS>
    </SIGNONMSGSRSV1>
    <CREDITCARDMSGSRSV1>
        <CCSTMTTRNRS>
            <TRNUID>0
            <STATUS>
                <CODE>0
                <SEVERITY>INFO
            </STATUS>
            <CCSTMTRS>
                <CURDEF>USD
                <CCACCTFROM>
                    <ACCTID>{account_id}
                    <DOWNLOAD.FLAG>true
                    <DOWNLOAD.TYPE>downloadDates
                    <AMEX.BASICACCT>{account_id}
                    <AMEX.ROLE>B
                    <AMEX.UNIVID>{uuid.uuid4().hex}
                </CCACCTFROM>
                <BANKTRANLIST>
                    <DTSTART>{dtstart}
                    <DTEND>{dtend}
"""
    txn_blocks = []
    for txn in transactions:
        date = txn.get("date") + "000000.000[-7:MST]"
        amount = txn.get("amount")
        name = txn.get("name")
        memo = txn.get("memo")
        fitid = txn.get("fitid") or str(uuid.uuid4().int)[:18]

        txn_block = f"""                    <STMTTRN>
                        <TRNTYPE>DEBIT
                        <DTPOSTED>{date}
                        <TRNAMT>{amount}
                        <FITID>{fitid}
                        <REFNUM>{fitid}
                        <NAME>{name}
                        <MEMO>{memo}
                    </STMTTRN>
"""
        txn_blocks.append(txn_block)

    ledger = f"""                </BANKTRANLIST>
                <LEDGERBAL>
                    <BALAMT>-100.00
                    <DTASOF>{dtend}
                </LEDGERBAL>
                <CYCLECUT.INDICATOR>false
                <PURGE.INDICATOR>false
                <INTL.INDICATOR>false
            </CCSTMTRS>
        </CCSTMTTRNRS>
    </CREDITCARDMSGSRSV1>
</OFX>
"""

    content = header + signon + "".join(txn_blocks) + ledger
    Path(output_file).write_text(content, encoding="utf-8")
    print(f"[+] OFX file written to {output_file}")

def interactive_mode():
    print("=== OFX Payload Generator ===")
    account_id = input("Enter account number (default 555555555555555): ").strip() or "555555555555555"
    n = int(input("How many transactions do you want? "))

    transactions = []
    today = datetime.datetime.now().strftime("%Y%m%d")

    for i in range(n):
        print(f"\n--- Transaction {i+1} ---")
        date = input(f"Date (YYYYMMDD, default {today}): ").strip() or today
        amount = input("Amount (default 1.00): ").strip() or "1.00"
        name = input("Payload for NAME field: ").strip() or "TestName"
        memo = input("Payload for MEMO field: ").strip() or "TestMemo"
        fitid = input("FITID (leave blank for random): ").strip()

        transactions.append({
            "date": date,
            "amount": amount,
            "name": name,
            "memo": memo,
            "fitid": fitid
        })

    filename = input("Output file name (default payload_test.ofx): ").strip() or "payload_test.ofx"
    generate_ofx(account_id, transactions, filename)

if __name__ == "__main__":
    interactive_mode()
