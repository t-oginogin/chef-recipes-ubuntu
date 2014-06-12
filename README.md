For Ubuntu 14.04 LTS 64bit

1. repipe取得

    git clone https://github.com/t-oginogin/chef-recipes-ubuntu.git ~/chef-repo

2. lohalhost.json内のパラメータ（user,passwordなど）を適宜変更

3. solo.rb内のcookbook_pathを適宜変更

4. recipe実行

    sudo chef-solo -c solo.rb -j ./localhost.json
