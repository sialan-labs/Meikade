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

#ifndef THREADEDFILESYSTEM_H
#define THREADEDFILESYSTEM_H

#include <QObject>

class ThreadedFileSystemPrivate;
class ThreadedFileSystem : public QObject
{
    Q_OBJECT
public:
    ThreadedFileSystem(QObject *parent = 0);
    ~ThreadedFileSystem();

public slots:
    void copy( const QString & src, const QString & dst );

signals:
    void copyFinished( const QString & dst );
    void copyError();

private slots:
    void copy_prv( const QString & src, const QString & dst );

private:
    ThreadedFileSystemPrivate *p;
};

#endif // THREADEDFILESYSTEM_H
