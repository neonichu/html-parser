#!/bin/sh

GH_DTHTML=https://raw.github.com/Cocoanetics/DTFoundation/master/Core/Source/DTHTMLParser

mkdir -p DTHTMLParser
cd DTHTMLParser
rm -f *.h *.m
curl -s -O $GH_DTHTML/DTHTMLParser.h
curl -s -O $GH_DTHTML/DTHTMLParser.m
