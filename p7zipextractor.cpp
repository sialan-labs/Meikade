/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "p7zipextractor.h"

#include <QAndroidJniEnvironment>
#include <QAndroidJniObject>

class P7ZipExtractorPrivate
{
public:
    QAndroidJniObject object;
    QAndroidJniEnvironment env;
};

P7ZipExtractor::P7ZipExtractor(QObject *parent) :
    QObject(parent)
{
    p = new P7ZipExtractorPrivate;
    p->object = QAndroidJniObject("SevenZip/J7zip");
}

void P7ZipExtractor::extract(const QString &path, const QString & dest)
{
    jstring jpath = p->env->NewString(reinterpret_cast<const jchar*>(path.constData()), path.length());
    jstring jdest = p->env->NewString(reinterpret_cast<const jchar*>(dest.constData()), dest.length());
    p->object.callMethod<jboolean>("extract", "(Ljava/lang/String;Ljava/lang/String;)Z", jpath, jdest );
}

void P7ZipExtractor::staticExtract(const QString &path, const QString &dest)
{
    QAndroidJniObject jpath = QAndroidJniObject::fromString(path.toUtf8());
    QAndroidJniObject jdest = QAndroidJniObject::fromString(dest.toUtf8());
    QAndroidJniObject::callStaticObjectMethod("SevenZip/J7zip",
                                              "extract",
                                              "(Ljava/lang/String;Ljava/lang/String;)Z",
                                              jpath.object<jstring>(),
                                              jdest.object<jstring>());
}

P7ZipExtractor::~P7ZipExtractor()
{
    delete p;
}
