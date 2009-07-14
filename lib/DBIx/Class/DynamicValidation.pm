package DBIx::Class::DynamicValidation;
use strict;
use warnings;

use base qw/DBIx::Class/;
use Carp;
use UNIVERSAL::require;

__PACKAGE__->mk_classdata( validator => 'FormValidator::Simple' );
__PACKAGE__->mk_classdata( validator_plugins => [] );

=head1 NAME

DBIx::Class::DynamicValidation

=head1 SYNOPSIS

Write 'validation' method in your schema object class.

    __PACKAGE__->load_components( 'DynamicValidation' );

    sub validation {
        my $self = shift;
        [
            name      => [ qw/NOT_BLANK/ ],
            email     => [ qw/EMAIL_LOOSE/ ],
            introduce => [ qw/NOT_BLANK/, [ qw/LENGTH 0 50000/ ] ],
        ];
    }

If you want to use any plugins for FV::Simple, set 'validator_plugins'.

    sub validation {
        my $self = shift;
        [
            name      => [ qw/NOT_BLANK ASCII/, [ qw/LENGTH 0 255/ ] ],
            email     => [ qw/NOT_BLANK/, [ qw/LENGTH 0 255/ ] ],
            password  => [ qw/NOT_BLANK/, [ qw/LENGTH 0 255/ ] ],
            deleted   => [ qw/UINT/, [ qw/BETWEEN 0 1/ ] ],

            { name   => [ qw/id name/ ] } => [ [ 'DBIC_UNIQUE', $self->result_source->resultset, '!id', 'name' ] ],
        ];
    }

    __PACKAGE__->validator_plugins( qw(
        FormValidator::Simple::Plugin::DBIC::Unique
    ) );

=head1 DESCRIPTION

Validate model object when they have inserted or updated automatically.

You can use FormValidator::Simple and their plugins as a validator.

=head1 METHODS

=head2 validate()

abstract.
when validation failed, throw exception.

=cut
sub validate {
    my $self = shift;
    return unless defined $self->validation;

    my %data = $self->get_columns;
    my $module = $self->validator;
    $module->require;
    if ( $self->validator_plugins ) {
        $module->load_plugin($_) for $self->validator_plugins;
    }
    my $result = $module->check(\%data => $self->validation);
    croak $result unless $result->success;
}

=head2 insert

call validate() before insert.

=cut
sub insert {
    my $self = shift;
    $self->validate;
    $self->next::method(@_);
}

=head2 update

call validate() before update.

=cut
sub update {
    my $self = shift;
    $self->validate;
    $self->next::method(@_);
}

=head1 AUTHOR

Ryo Miyake <ryo.studiom@gmail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
