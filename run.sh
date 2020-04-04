#!/bin/bash
cd "`dirname $0`"

rm score-*.json

for r in `seq 1 200 40000`; do
	p="`echo -n '{"min_rank":'$r',"num_consecutive_users":200}' |base64 |tr -d =`"
	url="https://codejam.googleapis.com/scoreboard/000000000019fd27/poll?p=$p"

	(curl -s "$url"; echo =) \
	|base64 -D |jq . > score-$r.json \
	&& echo -n . &
done

wait

echo "Rank\tScore\tPenalty\tCountry\tName" > score.tsv
echo "Rank\tScore\tPenalty\tCountry\tName" > score-taiwan.tsv

cat score-*.json \
	|jq -r '.user_scores[] |[.rank, .score_1, .score_2, .country, .displayname] |@tsv' \
	|sort -n \
	|cut -d $'\t' -f 2- >> score.tsv

grep -P '\tTaiwan\t' score.tsv >> score-taiwan.tsv

git add .
git commit -m "`date '+%b %d  %H:%M'`"
git push
