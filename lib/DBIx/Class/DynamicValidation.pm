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

=head1 DESCRIPTION

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
