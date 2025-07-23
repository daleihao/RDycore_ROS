function [r, RMSE, KGE] = calc_KGE(sim, obs)
    % 计算 Kling-Gupta Efficiency (KGE)
    % 输入:
    %   sim: 模拟值向量
    %   obs: 观测值向量
    % 输出:
    %   KGE: Kling-Gupta Efficiency 值

    % 去除 NaN
    valid_idx = ~isnan(sim) & ~isnan(obs);
    sim = sim(valid_idx);
    obs = obs(valid_idx);

    % 皮尔逊相关系数
    r = corr(sim, obs);

    RMSE = sqrt(mean((sim-obs).^2));
    % 均值比
    beta = mean(sim) / mean(obs);

    % 变异系数比
    gamma = (std(sim)/mean(sim)) / (std(obs)/mean(obs));

    % 计算 KGE
    KGE = 1 - sqrt((r - 1)^2 + (beta - 1)^2 + (gamma - 1)^2);
end
