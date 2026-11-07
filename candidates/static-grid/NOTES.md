# Static fee grid

Pinned simulator: `6b6921f8d463314aa7c96234e1be25a25245f704`. Selected **75/75 bps** (bid/ask) on seeds 0–499.
Source SHA-256: `5837798b91013de606cce87771bc2f4d40d0ae43b7b75aeab9c7a55e2e18670c`.

Seeds 0–999 candidate mean edge: **380.14166843**. Vanilla 30/30 mean: **343.60101071**.
Fresh 100000–101999 versus starter: **+10.60994291 ± 0.16035916 SE**, n=2000. Promotion criterion passed: True.

The starter is also the previous best available to this item. No separate network-best contract was supplied. The local vanilla score does not reproduce the public ~522 baseline, so these scores must not be compared directly with the board. Nothing was fabricated.

## Paired grid

Each row uses seeds 0–499 against the same fixed-50 starter. SE = sample SD(candidate edge − starter edge) / sqrt(500). All ordered asymmetric pairs are included; duplicates are measured once. Ranked by training mean edge.

| Bid bps | Ask bps | n | Mean edge | Mean difference | SE | SHA-256 |
|---:|---:|---:|---:|---:|---:|---|
| 75 | 75 | 500 | 385.04951874 | +10.92472659 | 0.29693600 | `5837798b91013de606cce87771bc2f4d40d0ae43b7b75aeab9c7a55e2e18670c` |
| 80 | 80 | 500 | 384.97453980 | +10.84974765 | 0.34108228 | `6520f51b6731384562842a924284b66b18bf3689f908c86d16da046ff7ee6f76` |
| 70 | 70 | 500 | 384.45232089 | +10.32752874 | 0.24899112 | `37dca181b6f975dde04845451b7f2a48b80e4ac46a36ed6c4611c6455e8a7b01` |
| 85 | 85 | 500 | 384.32276496 | +10.19797280 | 0.38277549 | `c17bf016703804004c391537c6b4fad8bd7bb3340dfd5d650db726efeefc2e05` |
| 90 | 90 | 500 | 383.14515824 | +9.02036608 | 0.42154347 | `895fae67244a9e747ddd8f85d81e19a1dbd5cefe0c6b5584925abf272949bb36` |
| 65 | 65 | 500 | 383.14238011 | +9.01758795 | 0.19626725 | `f118e7c4afb3bbf620677f056e1ad35c0a7aa0d43f2b39f5b8931f355d484508` |
| 95 | 95 | 500 | 381.49829853 | +7.37350637 | 0.45832799 | `e12af1f02b60c32abe78fed87caed042d1ef8d889b8b66f688c5b956ed253189` |
| 60 | 60 | 500 | 381.03380927 | +6.90901712 | 0.13808317 | `3ef9ec4d8d83a2c3c10d874ad11031572c853b19ca41c9382ff12211442d78c7` |
| 100 | 100 | 500 | 379.46532904 | +5.34053688 | 0.49321804 | `25ebd020891133ac12593b0ad8a21b6d5ebdd70095be61b4bad23ebd018a4d0e` |
| 55 | 55 | 500 | 378.05615235 | +3.93136019 | 0.07263868 | `27ef763ca8a0129086e9760469cb9db5fcb0fdc08ec39f6a608918fe2b0d13c1` |
| 45 | 60 | 500 | 376.21617651 | +2.09138435 | 0.03747140 | `98fc3bb43cf2f813c3be6b325b54b9e9e80f899687f12ba3c06e5a89a997a40e` |
| 60 | 45 | 500 | 376.21524464 | +2.09045248 | 0.03752286 | `613dcc9df7dd1adbaf173f3aad400a7c2e0447610a7aeacb0d461051cffaf74b` |
| 50 | 50 | 500 | 374.12479215 | +0.00000000 | 0.00000000 | `ef2774dca15afb4073083b16953bf3f0c031fa7b066cd43670b2181a73688f55` |
| 30 | 60 | 500 | 369.17196846 | -4.95282369 | 0.08163140 | `428e2a54fb6884bd9fa0e5d8dcc6d8a1e4c60c268bd89c524aa7316df754007c` |
| 60 | 30 | 500 | 369.16936257 | -4.95542959 | 0.08148688 | `773c657dd1c2b107f612f4c89549ee9984c4ffc899ccd9e2dece11a1222444df` |
| 45 | 45 | 500 | 369.16036728 | -4.96442487 | 0.08161877 | `de874b5bcb082ebfa4e2f33c4cba67ef47b9303b09256f1a3066141ebc939fa3` |
| 20 | 60 | 500 | 363.08168023 | -11.04311193 | 0.17263407 | `d5fd4df2acb02f6d6edb5684a1a8331f7e94852f6843dd390101c955d9c44f24` |
| 60 | 20 | 500 | 363.07716919 | -11.04762296 | 0.17242279 | `75a7436d9548fcced8b5a06aab61306fd2ae89ac80e1a2d27ae65c942de989eb` |
| 40 | 40 | 500 | 363.05684106 | -11.06795109 | 0.17279939 | `84797b3515de0129dedd9f60dc25d0419604e0ac64b0588d929eadf6459f53c3` |
| 30 | 45 | 500 | 359.59201007 | -14.53278208 | 0.22271798 | `c560370dc3abca4fd2d0b4b5691d990bbdeb3e2aa5e12098b25a5cd363937487` |
| 45 | 30 | 500 | 359.59015141 | -14.53464074 | 0.22262619 | `257588fe87201aab1766716ab78bfa78bb2bff01e6f4f84a175896c066d02d61` |
| 35 | 35 | 500 | 355.89269151 | -18.23210064 | 0.27590044 | `5db2cc829e07a305ff81dc581c8febbcdff9082b5b525bf986ec51b05dc10ceb` |
| 20 | 45 | 500 | 352.02921476 | -22.09557740 | 0.33277039 | `b95d58737aacfd401cc42d9bc1c4e2d0c9b03b910fd85a02870841992a3ec4af` |
| 45 | 20 | 500 | 352.02582413 | -22.09896803 | 0.33262733 | `7677ad17ccc21c725a876338e77dcfd8adebb2b961df115f68f298dc9f076feb` |
| 30 | 30 | 500 | 347.66464303 | -26.46014913 | 0.39585275 | `ad4696358b9608a44cec19c9c1d7f832dfb3945b90823fe5f6dccdd03609a7ec` |
| 20 | 30 | 500 | 326.51923405 | -47.60555811 | 0.56271144 | `bbc205024a8c157709cecba43fdc2b702832ebb769ecb1d68dfe6d657ee5fcdf` |
| 30 | 20 | 500 | 326.51777188 | -47.60702028 | 0.56262490 | `8fb2b47cc0f12389fdd7e8d260151f9c34a06c8c93540515796fce43dfc22f0d` |
| 25 | 25 | 500 | 326.51125777 | -47.61353439 | 0.56271652 | `dad63b0f71a8e276158b8f4f7c2057b9e40f6b0756b2402dbb897cb8150f3d5b` |
| 20 | 20 | 500 | 285.73809001 | -88.38670214 | 0.80857070 | `be2f04e131a97ab23091cba0cd353f4decf36ee690fad923278e466650695128` |
| 15 | 15 | 500 | 229.94609460 | -144.17869755 | 1.13497006 | `0b226bb0336eb54011e5c2f53e3c524b23776d221eee7e1992aad1b7c45372ac` |
| 10 | 10 | 500 | 161.05732090 | -213.06747125 | 1.53433649 | `0b35c178cbce3fc8e845969e01fbbee831eb104456a4b74b3ebd2011f32f6bf8` |

The JSON records the five worst paired seeds for every candidate. A positive grid difference is exploratory, not a promotion.

## Fresh finalists

| Bid | Ask | n | Mean edge | Difference vs starter | SE |
|---:|---:|---:|---:|---:|---:|
| 75 | 75 | 2000 | 380.11124434 | +10.60994291 | 0.16035916 |
| 80 | 80 | 2000 | 380.00571138 | +10.50440995 | 0.18499917 |

The first row was selected before holdout evaluation. Holdout results do not select a different winner. Both finalists used all 2,000 requested seeds.

## Ranked promotions

| Rank | Pair | Gain over starter / previous best | SE |
|---:|---|---:|---:|
| 1 | 75/75 | +10.60994291 | 0.16035916 |

## Method and checks

- Pinned commit checked out in test/scratch/static-grid/simulator; built release Rust wheel with maturin and installed Python dependencies in scratch venv.
- Custom seed configs equal official MatchRunner._build_configs on all 12 fields for seeds 0..19; actual VanillaStrategy bytecode edges exactly equal fixed 30/30 edges on all 20 seeds.
- All grid candidates compiled using official SolidityCompiler (Solidity 0.8.24, optimizer 200, viaIR, Paris), enforcing opcode and storage restrictions.
- Grid: 500 equal seeds per candidate and starter; finalists: 2000 fresh equal seeds each and starter.
- amm-match validate candidates/static-grid/Strategy.sol: Validating strategy... | Compiling strategy... | Strategy 'Static Grid 75/75' validated successfully!
- Source SHA-256 recomputed; JSON parsed and embedded source checked against Strategy.sol; bundle paths and size checked.
- Fixed 50/50 per-seed edges exactly equal the starter for all 500 grid seeds; all 31 requested pairs are present. CLI vanilla score agrees with the custom 1000-seed run within its printed precision.
- Independent CLI vanilla run: Validating strategy... | Compiling strategy... | Strategy: Vanilla_30bps |  | Running 1000 simulations... |  | Vanilla_30bps Edge: 343.60

Batch timing: 0.06393044 wall seconds per simulation with eight workers, averaged across 23000 completed unique simulations. Pilot: 0.06472103 s/simulation. Compilation and serialization excluded. Batches of 20 bound the simulator’s retained step history. Reused reference runs avoid duplicate work.

## Failures and limitations

- Initial `python -m venv` failed: python command not found; used python3.
- Initial maturin build failed: cargo not found; installed workspace-local Rust.
- Initial rustup installer failed because /tmp was absent; retried successfully with workspace TMPDIR.
- Local vanilla score differs materially from the externally reported ~522. The pinned README itself says 250-350 for the normalizer; the cause of the public-score difference is unverified. No claim of leaderboard parity or first place.
- No previous network-best source was provided, so the previous-best comparison is the supplied starter.
- No numbers or missing measurements fabricated.

## Sources

- [https://github.com/benedictbrady/amm-challenge/tree/6b6921f8d463314aa7c96234e1be25a25245f704](https://github.com/benedictbrady/amm-challenge/tree/6b6921f8d463314aa7c96234e1be25a25245f704): Pinned simulator, source, official compiler/validator and configuration. Its README quotes a typical normalizer edge of 250-350.
- [https://www.paradigm.xyz/puzzles/amm](https://www.paradigm.xyz/puzzles/amm): Challenge landing page; browser tool failed, curl succeeded.
- [https://github.com/dipankar/amm-challenge/blob/main/ANALYSIS.md](https://github.com/dipankar/amm-challenge/blob/main/ANALYSIS.md): Public first-person write-up discusses hidden-state estimation versus trade classification; contextual only, no mechanism adopted.
- [https://github.com/jiayaoqijia/amm-challenge-yq](https://github.com/jiayaoqijia/amm-challenge-yq): Public author reports cross-seed fixed-30 baseline 522.13; this is external context, not reproduced at pinned commit.

## Reproduction

Scratch setup commands (not submitted dependencies):
```bash
git clone https://github.com/benedictbrady/amm-challenge test/scratch/static-grid/simulator
git -C test/scratch/static-grid/simulator checkout 6b6921f8d463314aa7c96234e1be25a25245f704
python3 -m venv test/scratch/static-grid/venv
test/scratch/static-grid/venv/bin/pip install -e test/scratch/static-grid/simulator maturin
# Build amm_sim_rs with maturin build --release, install wheel in venv.
# Point SOLCX_BINARY_PATH to a scratch directory containing solc-v0.8.24.
test/scratch/static-grid/venv/bin/python test/scratch/static-grid/measure.py pilot
test/scratch/static-grid/venv/bin/python test/scratch/static-grid/measure.py grid
test/scratch/static-grid/venv/bin/python test/scratch/static-grid/measure.py final
test/scratch/static-grid/venv/bin/amm-match validate candidates/static-grid/Strategy.sol
```

Save the exact measurement harness below as test/scratch/static-grid/measure.py. Run from the checkout root with the scratch venv after installing the pinned simulator. It checkpoints arrays in scratch; no history or state is kept in Strategy.sol.
```python
import json, time, math, hashlib, argparse
from pathlib import Path
import numpy as np
import amm_sim_rs
from amm_competition.evm.compiler import SolidityCompiler
from amm_competition.evm.baseline import get_vanilla_bytecode_and_abi
from amm_competition.competition.config import build_config
ROOT=Path('test/scratch/static-grid')
OUT=ROOT/'measurements'; OUT.mkdir(exist_ok=True)
TEMPLATE='''// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {TradeInfo} from "./IAMMStrategy.sol";

/// @notice Fixed fees selected by paired static-grid measurements.
contract Strategy is AMMStrategyBase {
    uint256 public constant BID_FEE = BID_VALUE * BPS;
    uint256 public constant ASK_FEE = ASK_VALUE * BPS;

    function afterInitialize(uint256, uint256) external pure override returns (uint256, uint256) {
        return (BID_FEE, ASK_FEE);
    }

    function afterSwap(TradeInfo calldata) external pure override returns (uint256, uint256) {
        return (BID_FEE, ASK_FEE);
    }

    function getName() external pure override returns (string memory) {
        return "Static Grid BID_VALUE/ASK_VALUE";
    }
}
'''
def source(b,a): return TEMPLATE.replace('BID_VALUE',str(b)).replace('ASK_VALUE',str(a))
def configs(start,n):
    out=[]
    for i in range(start,start+n):
        rng=np.random.default_rng(seed=i)
        size=rng.uniform(19,21); rate=rng.uniform(.6,1); sigma=rng.uniform(.000882,.001008)
        out.append(build_config(seed=i,gbm_sigma=sigma,retail_arrival_rate=rate,retail_mean_size=size))
    return out
compiler=SolidityCompiler()
vanilla,_=get_vanilla_bytecode_and_abi()
def compile_code(code):
    c=compiler.compile(code)
    assert c.success,c.errors
    return c.bytecode
starter=(ROOT/'simulator/contracts/src/StarterStrategy.sol').read_text()
def run(label,code,start,n):
    path=OUT/f'{label}_{start}.json'
    data=json.loads(path.read_text()) if path.exists() else {'label':label,'seed_start':start,'edges':[],'seconds':0,'sha256':hashlib.sha256(code.encode()).hexdigest()}
    assert data['sha256']==hashlib.sha256(code.encode()).hexdigest()
    bytecode=compile_code(code)
    while len(data['edges'])<n:
        offset=len(data['edges']); k=min(20,n-offset)
        cfg=configs(start+offset,k)
        t=time.perf_counter(); result=amm_sim_rs.run_batch(list(bytecode),list(vanilla),cfg,8)
        edges=[float(r.edges['submission']) for r in result.results]
        assert [r.seed for r in result.results]==list(range(start+offset,start+offset+k))
        data['seconds']+=time.perf_counter()-t
        data['edges']+=edges
        del result
        path.write_text(json.dumps(data))
        if len(data['edges'])%100==0 or len(data['edges'])==n:
            print(label,start,len(data['edges']),round(np.mean(data['edges']),6),'sec',round(data['seconds'],2),flush=True)
    return data

def stats(candidate,ref):
    d=np.array(candidate['edges'])-np.array(ref['edges'])
    return {'n':len(d),'mean_edge':float(np.mean(candidate['edges'])),'mean_diff':float(np.mean(d)),'se':float(np.std(d,ddof=1)/math.sqrt(len(d))),'worst':[{'seed':candidate['seed_start']+int(i),'diff':float(d[i])} for i in np.argsort(d)[:5]]}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('phase',choices=['pilot','grid','final']); args=p.parse_args()
    if args.phase=='pilot':
        a=run('starter',starter,0,20);b=run('30_30',source(30,30),0,20)
        print('PILOT_SECONDS_PER_SIM', (a['seconds']+b['seconds'])/40,flush=True)
    if args.phase=='grid':
        ref=run('starter',starter,0,500)
        pairs=sorted(set([(v,v) for v in range(10,101,5)]+[(b,a) for b in [20,30,45,60] for a in [20,30,45,60]]))
        table=[]
        for b,a in pairs:
            r=run(f'{b}_{a}',source(b,a),0,500);row={'bid':b,'ask':a,**stats(r,ref),'sha256':hashlib.sha256(source(b,a).encode()).hexdigest()};table.append(row)
            (OUT/'grid.json').write_text(json.dumps(sorted(table,key=lambda x:-x['mean_edge']),indent=2))
        run('30_30',source(30,30),0,1000)
    if args.phase=='final':
        table=json.loads((OUT/'grid.json').read_text()); best=table[:2]
        ref=run('starter',starter,100000,2000)
        final=[]
        for row in best:
            b,a=row['bid'],row['ask'];r=run(f'{b}_{a}',source(b,a),100000,2000)
            final.append({'bid':b,'ask':a,**stats(r,ref),'sha256':row['sha256']})
        (OUT/'final.json').write_text(json.dumps(final,indent=2))
        winner=best[0];run(f"{winner['bid']}_{winner['ask']}",source(winner['bid'],winner['ask']),0,1000)
        Path('candidates/static-grid/Strategy.sol').write_text(source(winner['bid'],winner['ask']))

```

## Next

- Reconcile pinned-commit vanilla score with the public ~522 baseline before comparing to leaderboard.
- Measure a finer fixed-fee grid near the training winner on unused tuning seeds, with a new untouched holdout.
- Use these fixed-fee results as controls for fair-price and volatility estimation strategies in other items.

## Final independent verification

Independent Python statistics.mean/stdev recomputation passed for all 31 grid rows and both 2000-seed finalists, including all five worst per-seed differences. Identical JSON output copies, source content/SHA-256, required file existence, 64000-byte JSON cap, and 8 MiB bundle cap verified.

Fresh paired 75/75 minus 80/80: +0.10553296 ± 0.02640010 SE, n=2000. This also favors the training-selected winner.
