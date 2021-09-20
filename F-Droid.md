# How to update F-Droid yml

```
$ git remote -v
fdroid	https://gitlab.com/fdroid/fdroiddata.git (fetch)
fdroid	https://gitlab.com/fdroid/fdroiddata.git (push)
origin	https://gitlab.com/calcitem/fdroiddata.git (fetch)
origin	https://gitlab.com/calcitem/fdroiddata.git (push)
    
git remote update
git reset --hard fdroid/master 

vi /home/calcitem/code/fdroiddata/metadata/com.calcitem.sanmill.yml

fdroid lint com.calcitem.sanmill
fdroid update com.calcitem.sanmill
fdroid rewritemeta com.calcitem.sanmill

git add .
git commit -m "Update Mill to 1.1.33 (2167)"
git push origin HEAD:calcitem/master -f
```

https://gitlab.com/calcitem/fdroiddata/-/pipelines

https://gitlab.com/calcitem/fdroiddata/-/merge_requests/new#
