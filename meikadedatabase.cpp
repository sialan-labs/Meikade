/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Meikade is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Meikade is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "meikadedatabase.h"
#include "threadedfilesystem.h"
#include "meikade_macros.h"
#include "meikade.h"

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>
#include <QFile>
#include <QFileDevice>
#include <QDir>
#include <QDebug>

class MeikadeDatabasePrivate
{
public:
    QSqlDatabase db;
    QString path;
    QString src;

    QMultiHash<int,int> childs;
    QHash<int,int> parents;

    QHash<int, QHash<QString,QVariant> > cats;
    QHash<int, QHash<QString,QVariant> > poems_cache;

    ThreadedFileSystem *tfs;
    bool initialized;
};

MeikadeDatabase::MeikadeDatabase(ThreadedFileSystem *tfs, QObject *parent) :
    QObject(parent)
{
    p = new MeikadeDatabasePrivate;
    p->tfs = tfs;
    p->initialized = false;

    initialize();
}

bool MeikadeDatabase::initialized() const
{
    return p->initialized;
}

void MeikadeDatabase::initialize()
{
#ifdef Q_OS_ANDROID
    p->path = "/sdcard/Sialan/Meikade/data.sqlite";
    p->src = "assets:/database/data.sqlite";
    QDir().mkpath("/sdcard/Sialan/Meikade");
#else
    p->path = HOME_PATH + "/data.sqlite";
    p->src = "database/data.sqlite";
#endif

    bool force = false;
    if( QFileInfo(p->src).size() != QFileInfo(p->path).size() )
    {
        force = true;
        QFile::remove(p->path);
    }

    if( force || !Meikade::settings()->value("initialize/data_db",false).toBool() )
    {
        connect( p->tfs, SIGNAL(copyFinished(QString)), SLOT(initialize_prv()), Qt::QueuedConnection );
#ifdef Q_OS_ANDROID
        p->tfs->copy(p->src ,p->path);
#else
        p->tfs->copy(p->src ,p->path);
#endif
    }
    else {
        QMetaObject::invokeMethod( this, "initialize_prv", Qt::QueuedConnection );
        p->initialized = true;
    }
}

void MeikadeDatabase::initialize_prv()
{
    disconnect( p->tfs, SIGNAL(copyFinished(QString)), this, SLOT(initialize_prv()) );

    Meikade::settings()->setValue("initialize/data_db",true);
    QFile(p->path).setPermissions(QFileDevice::ReadUser|QFileDevice::ReadGroup);

    p->db = QSqlDatabase::addDatabase("QSQLITE",DATA_DB_CONNECTION);
    p->db.setDatabaseName(p->path);
    p->db.open();

    p->initialized = true;
    init_buffer();

    emit initializeFinished();
}

QList<int> MeikadeDatabase::rootChilds() const
{
    return childsOf(0);
}

QList<int> MeikadeDatabase::childsOf(int id) const
{
    QList<int> childs = p->childs.values(id);
    qSort( childs.begin(), childs.end() );
    return childs;
}

int MeikadeDatabase::parentOf(int id) const
{
    return p->parents.value(id);
}

QString MeikadeDatabase::catName(int id)
{
    return p->cats[id].value("text").toString();
}

QList<int> MeikadeDatabase::catPoems(int cat)
{
    QList<int> result;

    QSqlQuery query( p->db );
    query.prepare("SELECT id, title, url, cat_id FROM poem WHERE cat_id=:cat");
    query.bindValue(":cat",cat);
    query.exec();

    while( query.next() )
    {
        QSqlRecord record = query.record();
        int id = record.value(0).toInt();
        for( int i=0; i<record.count(); i++ )
            p->poems_cache[id].insert( record.fieldName(i), record.value(i) );

        result << id;
    }

    return result;
}

QString MeikadeDatabase::poemName(int id)
{
    if( !p->poems_cache.value(id).contains("title") )
    {
        QSqlQuery query( p->db );
        query.prepare("SELECT title FROM poem WHERE id=:id");
        query.bindValue(":id",id);
        query.exec();

        if( !query.next() )
            return 0;

        p->poems_cache[id]["title"] = query.record().value(0).toString();
    }

    return p->poems_cache[id].value("title").toString();
}

int MeikadeDatabase::poemCat(int id)
{
    if( !p->poems_cache.value(id).contains("cat_id") )
    {
        QSqlQuery query( p->db );
        query.prepare("SELECT cat_id FROM poem WHERE id=:id");
        query.bindValue(":id",id);
        query.exec();

        if( !query.next() )
            return 0;

        p->poems_cache[id]["cat_id"] = query.record().value(0).toInt();
    }

    return p->poems_cache[id].value("cat_id").toInt();
}

QList<int> MeikadeDatabase::poemVerses(int id)
{
    QList<int> result;

    QSqlQuery query( p->db );
    query.prepare("SELECT vorder FROM verse WHERE poem_id=:id");
    query.bindValue(":id",id);
    query.exec();

    while( query.next() )
    {
        QSqlRecord record = query.record();
        result << record.value(0).toInt();
    }

    return result;
}

QString MeikadeDatabase::verseText(int pid, int vid)
{
    QSqlQuery query( p->db );
    query.prepare("SELECT text FROM verse WHERE poem_id=:pid AND vorder=:vid");
    query.bindValue(":pid",pid);
    query.bindValue(":vid",vid);
    query.exec();

    if( !query.next() )
        return QString();

    return query.record().value(0).toString();
}

int MeikadeDatabase::versePosition(int pid, int vid)
{
    QSqlQuery query( p->db );
    query.prepare("SELECT position FROM verse WHERE poem_id=:pid AND vorder=:vid");
    query.bindValue(":pid",pid);
    query.bindValue(":vid",vid);
    query.exec();

    if( !query.next() )
        return 0;

    return query.record().value(0).toInt();
}

void MeikadeDatabase::init_buffer()
{
    p->childs.clear();
    p->cats.clear();
    p->parents.clear();

    QSqlQuery cats_query( p->db );
    cats_query.prepare("SELECT id, parent_id, poet_id, text, url FROM cat");
    cats_query.exec();

    while( cats_query.next() )
    {
        QSqlRecord record = cats_query.record();

        int id = record.value(0).toInt();
        p->childs.insertMulti( record.value(1).toInt(), id );
        p->parents.insert( id, record.value(1).toInt() );

        for( int i=0; i<record.count(); i++ )
            p->cats[id].insert( record.fieldName(i), record.value(i) );
    }
}

MeikadeDatabase::~MeikadeDatabase()
{
    delete p;
}
