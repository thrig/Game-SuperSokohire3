# -*- Perl -*-
#
# $Id: Scrolls.pm,v 1.2 2022/06/04 01:11:43 jmates Exp $
#
# see also eg/enscroll

package Game::SuperSokohire3::Scrolls 0.02;
use Game::SuperSokohire3::Random 'extract';

our @scrolls = (
    "49n gMbn i1OiXfDnO D9fD D9n kvi1Xn 9fO Nnn1 vn8CtnO DC f vn8CDn Ff8iuZ tiuuf FCv 9nfuD9 vnfhC1h.",
    "49n SfvqMih feenfvnO DCOfZ QiD9 8n8Nnvh CF D9n XunvcZ JMhD NnFCvn f 8nnDi1c QiD9 evC8i1n1D XiDiIn1h.",
    "Sfvvifcn Nnuuh? 49n rMnn1 Qfh hnn1 9fti1c f XuChn cfvOn1 hDvCuu QiD9 D9n gMbn FCuuCQi1c D9n XCM1Xiu X9f8Nnvh DCOfZ.",
    "GM8Cvh hQivunO Ctnv hnn8i1cuZ nvvfDiX Nn9ftiCv CF D9n rMnn1'h hC1. Si1ihDnvh Oih8ihhnO D9n vneCvDh fh iOun X9fDDnv.",
    "Si1ihDnvh vneCvD D9fD D9n bi1c 9fO cC1n 8ihhi1c fFDnv f 9M1Di1c nyenOiDiC1 QiD9 9ih XuChn Fvin1O D9n lfvC1.",
    "49n SfvqMih i1OiXfDnO D9fD 9n QCMuO, QiD9 vnuMXDf1Xn, Nn Qiuui1c DC Fiuu D9n unfOnvh9ie tCiO.",
    "49n lfvC1 DCOfZ On1inO vM8Cvh 9n 9fO Nnn1 XMvvZi1c FftCv QiD9 8i1ihDnvh CF D9n CeeChiDiC1.",
    "49n hC1 CF D9n rMnn1 vnDMv1nO DC D9n efufXn DCOfZ 9fti1c hen1D fh CMv vnfOnvh Qiuu b1CQ hntnvfu Znfvh fNvCfO.",
);

# keygen:
#   perl -MList::Util=shuffle -E 'say join "", shuffle "A".."Z","a".."z",0..9'
sub decrypt ($) {
    my ($s) = @_;
    $s =~
      tr/alpgoBm2TR3LSAskrGd4V5wYPWfNXOnFc9iJbu81CeqvhDMtQyZIxKEHz0j6U7/A-Za-z0-9/;
    return $s;
}

sub encrypt ($) {
    my ($s) = @_;
    $s =~
      tr/A-Za-z0-9/alpgoBm2TR3LSAskrGd4V5wYPWfNXOnFc9iJbu81CeqvhDMtQyZIxKEHz0j6U7/;
    return $s;
}

sub text { decrypt extract \@scrolls }

1;
__END__
=head1 NAME

Game::SuperSokohire3::Scrolls - magic scroll support

=cut
