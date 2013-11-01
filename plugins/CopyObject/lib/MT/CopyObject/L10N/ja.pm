package MT::CopyObject::L10N::ja;

use strict;
use utf8;
use base 'MT::CopyObject::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
	'Enables coping an object on management screen.'
		=> '管理画面でのオブジェクトの複製を可能にします。',
	'Copy of [_1]' => 'コピー: [_1]',
	'Copy As New Entry' => '新しい記事として複製',
	'Copy As New Page' => '新しいウェブページとして複製',
	'Copy from <a href="[_1]">id:[_2]</a>'
		=> '<a href="[_1]">id:[_2]</a> からの複製',

    'Copy Fields' => 'まとめて複製',
    'How many copy for each?' => 'いくつずつ複製しますか？',
    'Successfully [_1] time(s) copied about [_2] field(s).'
        => '[_2]件のカスタムフィールドを[_1]回ずつ複製しました',
);

1;

