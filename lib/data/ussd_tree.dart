// lib/data/ussd_tree.dart

const ussdTree = {
  'MTN': {
    'Solde': '*104#',
    'Mon numéro': '*103#',
    'Portail unique': '*199#',
    'Internet': {
      'Menu Internet': '*123#',
      'Forfait 200F - 100Mo (24h)': '*123*10*1#',
      'Forfait 500F - 500Mo (24h)': '*123*10*2#',
      'Forfait 1000F - 1.2Go (7j)': '*123*11*1#',
      'Forfait 2000F - 3Go (30j)': '*123*12*1#',
    },
    'Appels': {
      'Menu Appels': '*173#',
      'Maxi 500F': '*173*1#',
      'Maxi 1000F': '*173*2#',
    },
    'Mobile Money (MoMo)': {
      'Menu MoMo': '*880#',
      'Envoyer argent': {
        '__input__': ['Numéro destinataire', 'Montant (FCFA)'],
        '__ussd__': '*880*1*1*{{0}}*{{1}}*{{pin}}#',
      },
      'Consulter solde MoMo': '*880*2#',
      'Retrait argent': {
        '__input__': ['Code Agent', 'Montant (FCFA)'],
        '__ussd__': '*880*3*{{0}}*{{1}}*{{pin}}#',
      },
    },
    'Transfert crédit (Me2U)': {
      '__input__': ['Numéro destinataire', 'Montant (FCFA)'],
      '__ussd__': '*102*{{1}}*{{0}}*{{pin}}#',
    },
    'Service client': '111',
  },
  'MOOV': {
    'Solde': '*104#',
    'Mon numéro': '*199*1*3#',
    'Portail unique': '*199#',
    'Internet': {
      'Menu Internet': '*123#',
      'Forfait 200F - 150Mo (24h)': '*123*1*1#',
      'Forfait 500F - 600Mo (24h)': '*123*1*2#',
      'Forfait 1000F - 1.5Go (7j)': '*123*2*1#',
    },
    'Appels': {
      'Menu Appels': '*173#',
    },
    'Moov Money': {
      'Menu Moov Money': '*855#',
      'Transfert argent': {
        '__input__': ['Numéro destinataire', 'Montant (FCFA)'],
        '__ussd__': '*855*1*{{0}}*{{1}}*{{pin}}#',
      },
      'Solde Moov Money': '*855*5#',
    },
    'Transfert crédit (Me2U)': {
      '__input__': ['Numéro destinataire', 'Montant (FCFA)'],
      '__ussd__': '*102*{{1}}*{{0}}*{{pin}}#',
    },
    'Service client': '*708#',
  },
  'Celtiis': {
    'Solde': '*104#',
    'Mon numéro': '*104#',
    'Portail unique': '*199#',
    'Internet (IllimiNet)': {
      'Menu IllimiNet': '*199*4#',
      'Forfait 200F - 200Mo': '*199*4*1#',
    },
    'Celtiis Cash': {
      'Menu Cash': '*889#',
      'Transfert argent': {
        '__input__': ['Numéro destinataire', 'Montant (FCFA)'],
        '__ussd__': '*889*3*1*{{0}}*{{1}}#',
      },
    },
    'Service client': '7373',
  },
};
