#!/bin/bash
TEXTFILE_COLLECTOR_DIR=/opt/node_exporter/textfile_collector/
MYKEY=tcro1046hpqlc2aakwg9qfzn000fp2n4rzfwxefvg4l
VALIDATOR_ADDR="2676C65260C75A28BD554243E2945253F1690909"

BLOCKHEIGHT=$(curl -s localhost:26660/metrics | grep tendermint_consensus_height | grep -v HELP | grep -v TYPE | cut -d " " -f2)

SIGNING=$(curl -X GET -s "http://localhost:26657/block?height=165373" -H  "accept: application/json" | grep 2676C65260C75A28BD554243E2945253F1690909)
if [ -z "$SIGNING" ];then
    valisator_is_signing=0
else
    validator_is_signing=1
fi

AMOUNT=$(su - sentry -s /bin/bash -c '/opt/cro-sentry/bin/chain-maind --home /opt/cro-sentry/.chain-maind q bank balances $MYKEY | grep amount | cut -d " " -f3|sed "s/\"//g" ')
CRO=$(( AMOUNT / 100000000 ))

AMOUNT=$(su - sentry -s /bin/bash -c '/opt/cro-sentry/bin/chain-maind --home /opt/cro-sentry/.chain-maind q distribution rewards $MYKEY tcrocncl1046hpqlc2aakwg9qfzn000fp2n4rzfwxvk03du | grep amount | cut -d " " -f3 | sed "s/\"//g" | cut -d "." -f1 ')
REWARD=$(( AMOUNT / 100000000 ))

AMOUNT=$(su - sentry -s /bin/bash -c '/opt/cro-sentry/bin/chain-maind --home /opt/cro-sentry/.chain-maind q distribution commission tcrocncl1046hpqlc2aakwg9qfzn000fp2n4rzfwxvk03du | grep amount | cut -d " " -f3 | sed "s/\"//g" | cut -d "." -f1 ')
COMISSION=$(( AMOUNT / 100000000 ))

# Write out metrics to a temporary file.
cat << EOF > "$TEXTFILE_COLLECTOR_DIR/myscript.prom.$$"
myscript_validator_is_signing $validator_is_signing
myscript_balance $CRO
myscript_rewards $REWARD
myscript_comission $COMISSION
EOF

mv "$TEXTFILE_COLLECTOR_DIR/myscript.prom.$$" "$TEXTFILE_COLLECTOR_DIR/myscript.prom"
chown node_exporter "$TEXTFILE_COLLECTOR_DIR/myscript.prom"
