require "SodierCocos";

--AttackType
Attackinit=1;
AttackSet =2;
AttackDo  =3;
AttackOver=4;

SodierMatrix=class("SodierMatrix");
SodierMatrix.__index=SodierMatrix;

function SodierMatrix:ctor()
    self.m_pHero   = nil;
end

function SodierMatrix:init(pFather,count,kind,direct)
    self.m_nDirect = direct;
    self.m_bInSide = false;
    self.m_isMoveInIng = false;
    self.m_pFather = pFather; 
    self.m_nKind = kind;
    self:setSodierKind();
end


function SodierMatrix:setSodierKind()
    local kindname = Sodier.getSodierKindName(self.m_nKind);
    self.m_isDieIng = false;
    self.m_oAttackInfo.action = Attackinit;
    
    self.m_pSodierQueue = SODIER->getSodierQueue(kindname.c_str());
    
    if (m_Sodiers.size())
    {
        for (int i=0; i<m_Sodiers.size(); i++)
        {
            m_Sodiers[i]->removeFromParentAndCleanup(true);
        }
        m_Sodiers.clear();
    }
    
    for (int i= 0; i<m_pSodierQueue->count; i++)
    {
        MGSodierCocos* pSodier  = MGSodierCocos::create(m_pFather, m_nKind, m_nDirect);
        m_Sodiers.push_back(pSodier);
    }
end