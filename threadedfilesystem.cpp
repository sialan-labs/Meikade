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

#include "threadedfilesystem.h"

#include <QFile>
#include <QThread>
#include <QDebug>

class ThreadedFileSystemThread: public QThread
{
public:
    ThreadedFileSystemThread(QObject *child, QObject *parent): QThread(parent){
        child_obj = child;
    }
    ~ThreadedFileSystemThread() {
        delete child_obj;
    }

private:
    QObject *child_obj;
};

class ThreadedFileSystemPrivate
{
public:
    ThreadedFileSystemThread *thread;
};

ThreadedFileSystem::ThreadedFileSystem(QObject *parent) :
    QObject()
{
    p = new ThreadedFileSystemPrivate;
    p->thread = new ThreadedFileSystemThread(this,parent);

    moveToThread( p->thread );
    p->thread->start();
}

void ThreadedFileSystem::copy(const QString &src, const QString &dst)
{
    QMetaObject::invokeMethod( this, "copy_prv", Qt::QueuedConnection, Q_ARG(QString,src), Q_ARG(QString,dst) );
}

void ThreadedFileSystem::copy_prv(const QString &src, const QString &dst)
{
    QThread::sleep(3);
    QFile::copy(src,dst);
    emit copyFinished(dst);
}

ThreadedFileSystem::~ThreadedFileSystem()
{
    delete p;
}
